import 'package:dartz/dartz.dart' hide Task;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:taskflow/core/error/failures.dart';
import 'package:taskflow/core/theme/app_theme.dart';
import 'package:taskflow/features/tasks/domain/entities/task.dart';
import 'package:taskflow/features/tasks/domain/entities/task_details.dart';
import 'package:taskflow/features/tasks/domain/usecases/delete_task_usecase.dart';
import 'package:taskflow/features/tasks/domain/usecases/get_task_details_usecase.dart';
import 'package:taskflow/features/tasks/presentation/bloc/task_delete_bloc.dart';
import 'package:taskflow/features/tasks/presentation/bloc/task_details_bloc.dart';
import 'package:taskflow/features/tasks/presentation/pages/task_details_page.dart';

class MockGetTaskDetailsUseCase extends Mock implements GetTaskDetailsUseCase {}

class MockDeleteTaskUseCase extends Mock implements DeleteTaskUseCase {}

void main() {
  final getIt = GetIt.instance;
  late MockGetTaskDetailsUseCase getTaskDetails;
  late MockDeleteTaskUseCase deleteTask;

  const taskId = 'task_001';

  final task = Task(
    id: taskId,
    projectId: 'proj_001',
    title: 'Test Task to Delete',
    description: 'Will be deleted',
    status: TaskStatus.todo,
    priority: TaskPriority.high,
    assigneeId: null,
    dueDate: null,
    createdAt: DateTime(2026, 8, 1),
  );

  final taskDetails = TaskDetails(
    task: task,
    assignee: null,
    comments: const [],
  );

  setUp(() {
    getTaskDetails = MockGetTaskDetailsUseCase();
    deleteTask = MockDeleteTaskUseCase();

    getIt
      ..reset()
      ..registerFactory<GetTaskDetailsUseCase>(() => getTaskDetails)
      ..registerFactory<DeleteTaskUseCase>(() => deleteTask)
      ..registerFactory<TaskDetailsBloc>(
        () => TaskDetailsBloc(getTaskDetails),
      )
      ..registerFactory<TaskDeleteBloc>(
        () => TaskDeleteBloc(deleteTask),
      );
  });

  tearDown(() async {
    await getIt.reset();
  });

  Widget buildPage() {
    final router = GoRouter(
      initialLocation: '/tasks/$taskId',
      routes: [
        GoRoute(
          path: '/tasks/:taskId',
          builder: (context, state) => const TaskDetailsPage(taskId: taskId),
        ),
      ],
    );

    return MaterialApp.router(
      theme: AppTheme.dark(),
      routerConfig: router,
    );
  }

  testWidgets('shows confirmation dialog when delete icon button is tapped',
      (tester) async {
    when(() => getTaskDetails(taskId: taskId))
        .thenAnswer((_) async => Right(taskDetails));

    await tester.pumpWidget(buildPage());
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('deleteTaskButton')));
    await tester.pumpAndSettle();

    expect(find.text('Delete Task'), findsOneWidget);
    expect(find.text('Delete "Test Task to Delete"?\nThis action cannot be undone.'),
        findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
    expect(find.text('Delete'), findsWidgets);
  });

  testWidgets('cancel action closes confirmation dialog without deleting',
      (tester) async {
    when(() => getTaskDetails(taskId: taskId))
        .thenAnswer((_) async => Right(taskDetails));

    await tester.pumpWidget(buildPage());
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('deleteTaskButton')));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(find.text('Delete Task'), findsNothing);
    verifyNever(() => deleteTask(any()));
  });

  testWidgets('confirm delete executes deleteTask and navigates back',
      (tester) async {
    when(() => getTaskDetails(taskId: taskId))
        .thenAnswer((_) async => Right(taskDetails));
    when(() => deleteTask(taskId))
        .thenAnswer((_) async => const Right(unit));

    await tester.pumpWidget(buildPage());
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('deleteTaskButton')));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Delete').last);
    await tester.pumpAndSettle();

    verify(() => deleteTask(taskId)).called(1);
    expect(find.text('Task deleted successfully'), findsOneWidget);
  });

  testWidgets('shows error snackbar when delete fails', (tester) async {
    when(() => getTaskDetails(taskId: taskId))
        .thenAnswer((_) async => Right(taskDetails));
    when(() => deleteTask(taskId))
        .thenAnswer((_) async => const Left(UnknownFailure()));

    await tester.pumpWidget(buildPage());
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('deleteTaskButton')));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Delete').last);
    await tester.pumpAndSettle();

    verify(() => deleteTask(taskId)).called(1);
    expect(find.text('An unexpected error occurred.'), findsOneWidget);
  });
}
