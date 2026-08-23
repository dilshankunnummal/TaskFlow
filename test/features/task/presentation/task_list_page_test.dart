import 'dart:async';

import 'package:dartz/dartz.dart' hide Task;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:taskflow/core/error/failures.dart';
import 'package:taskflow/core/theme/app_theme.dart';
import 'package:taskflow/features/tasks/domain/entities/task.dart';
import 'package:taskflow/features/tasks/domain/repositories/task_repository.dart';
import 'package:taskflow/features/tasks/domain/usecases/get_project_tasks_usecase.dart';
import 'package:taskflow/features/tasks/presentation/bloc/task_list_bloc.dart';
import 'package:taskflow/features/tasks/presentation/pages/task_list_page.dart';

class MockGetProjectTasksUseCase extends Mock implements GetProjectTasksUseCase {}

class MockTaskRepository extends Mock implements TaskRepository {}

void main() {
  final getIt = GetIt.instance;
  late MockGetProjectTasksUseCase useCase;
  late MockTaskRepository repository;

  const projectId = 'proj_1';

  final task = Task(
    id: 'task_1',
    projectId: projectId,
    title: 'Design review',
    description: 'Review the new bento layout',
    status: TaskStatus.todo,
    priority: TaskPriority.high,
    assigneeId: 'user_1',
    dueDate: DateTime(2026, 9, 1),
    createdAt: DateTime(2026, 8, 1),
  );

  setUp(() {
    useCase = MockGetProjectTasksUseCase();
    repository = MockTaskRepository();
    getIt
      ..reset()
      ..registerFactory<GetProjectTasksUseCase>(() => useCase)
      ..registerFactory<TaskRepository>(() => repository)
      ..registerFactory<TaskListBloc>(
            () => TaskListBloc(getIt<GetProjectTasksUseCase>(), getIt<TaskRepository>()),
      );
  });

  tearDown(() async {
    await getIt.reset();
  });

  GoRouter buildRouter() {
    return GoRouter(
      initialLocation: '/projects/$projectId/tasks',
      routes: [
        GoRoute(
          path: '/projects/:projectId/tasks',
          builder: (context, state) => TaskListPage(projectId: state.pathParameters['projectId']!),
        ),
        GoRoute(
          path: '/tasks/:taskId',
          builder: (context, state) => Scaffold(
            body: Text('Task Details ${state.pathParameters['taskId']}'),
          ),
        ),
      ],
    );
  }

  testWidgets('shows a loading skeleton while tasks are being fetched', (tester) async {
    final completer = Completer<Either<Failure, List<Task>>>();
    when(() => useCase(projectId: projectId)).thenAnswer((_) => completer.future);

    await tester.pumpWidget(MaterialApp.router(theme: AppTheme.dark(), routerConfig: buildRouter()));
    await tester.pump();

    expect(find.byType(GridView), findsOneWidget);
    expect(find.text('Design review'), findsNothing);

    completer.complete(Right([task]));
    await tester.pumpAndSettle();
  });

  testWidgets('renders task cards on success', (tester) async {
    when(() => useCase(projectId: projectId)).thenAnswer((_) async => Right([task]));

    await tester.pumpWidget(MaterialApp.router(theme: AppTheme.dark(), routerConfig: buildRouter()));
    await tester.pumpAndSettle();

    expect(find.text('Design review'), findsOneWidget);
    expect(find.text('High'), findsOneWidget);
    expect(find.text('Todo'), findsOneWidget);
    expect(find.text('User 1'), findsOneWidget);
  });

  testWidgets('renders the empty state when the project has no tasks', (tester) async {
    when(() => useCase(projectId: projectId)).thenAnswer((_) async => const Right([]));

    await tester.pumpWidget(MaterialApp.router(theme: AppTheme.dark(), routerConfig: buildRouter()));
    await tester.pumpAndSettle();

    expect(find.text('No tasks yet'), findsOneWidget);
  });

  testWidgets('renders an error state with a retry action', (tester) async {
    when(() => useCase(projectId: projectId))
        .thenAnswer((_) async => const Left(ServerFailure('Unable to load tasks.')));

    await tester.pumpWidget(MaterialApp.router(theme: AppTheme.dark(), routerConfig: buildRouter()));
    await tester.pumpAndSettle();

    expect(find.text('Unable to load tasks.'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
  });

  testWidgets('pull to refresh calls refreshTasks and re-renders the list', (tester) async {
    when(() => useCase(projectId: projectId)).thenAnswer((_) async => Right([task]));
    when(() => repository.refreshTasks(projectId: projectId)).thenAnswer((_) async => Right([task]));

    await tester.pumpWidget(MaterialApp.router(theme: AppTheme.dark(), routerConfig: buildRouter()));
    await tester.pumpAndSettle();

    await tester.fling(find.byType(RefreshIndicator), const Offset(0, 300), 1000);
    await tester.pumpAndSettle();

    verify(() => repository.refreshTasks(projectId: projectId)).called(1);
    expect(find.text('Design review'), findsOneWidget);
  });

  testWidgets('navigates to the task detail route when a task card is tapped', (tester) async {
    when(() => useCase(projectId: projectId)).thenAnswer((_) async => Right([task]));

    await tester.pumpWidget(MaterialApp.router(theme: AppTheme.dark(), routerConfig: buildRouter()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Design review'));
    await tester.pumpAndSettle();

    expect(find.text('Task Details task_1'), findsOneWidget);
  });
}