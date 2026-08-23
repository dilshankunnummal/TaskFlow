import 'dart:async';
import 'package:dartz/dartz.dart' hide Task;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:taskflow/core/error/failures.dart';
import 'package:taskflow/core/theme/app_theme.dart';
import 'package:taskflow/features/tasks/domain/entities/task.dart';
import 'package:taskflow/features/tasks/domain/entities/task_assignee.dart';
import 'package:taskflow/features/tasks/domain/usecases/create_task_usecase.dart';
import 'package:taskflow/features/tasks/domain/usecases/get_assignees_usecase.dart';
import 'package:taskflow/features/tasks/presentation/bloc/task_create_bloc.dart';
import 'package:taskflow/features/tasks/presentation/pages/task_create_page.dart';

class MockCreateTaskUseCase extends Mock implements CreateTaskUseCase {}
class MockGetAssigneesUseCase extends Mock implements GetAssigneesUseCase {}

void main() {
  final getIt = GetIt.instance;
  late MockCreateTaskUseCase createTaskUseCase;
  late MockGetAssigneesUseCase getAssigneesUseCase;

  const projectId = 'proj_1';
  final tAssignees = [
    const TaskAssignee(id: '1', name: 'Ava Thompson', email: 'ava@test.com'),
  ];
  final tTask = Task(
    id: 'task_1',
    projectId: projectId,
    title: 'New Task',
    description: 'Task Desc',
    status: TaskStatus.todo,
    priority: TaskPriority.medium,
    assigneeId: '1',
    dueDate: DateTime(2027, 1, 1),
    createdAt: DateTime(2026, 8, 1),
  );

  setUp(() {
    createTaskUseCase = MockCreateTaskUseCase();
    getAssigneesUseCase = MockGetAssigneesUseCase();
    getIt
      ..reset()
      ..registerFactory<CreateTaskUseCase>(() => createTaskUseCase)
      ..registerFactory<GetAssigneesUseCase>(() => getAssigneesUseCase)
      ..registerFactory<TaskCreateBloc>(
        () => TaskCreateBloc(
          getIt<CreateTaskUseCase>(),
          getIt<GetAssigneesUseCase>(),
        ),
      );
  });

  tearDown(() async {
    await getIt.reset();
  });

  Widget buildPage() {
    return MaterialApp(
      theme: AppTheme.dark(),
      home: const TaskCreatePage(projectId: projectId),
    );
  }

  testWidgets('renders all form fields', (tester) async {
    when(() => getAssigneesUseCase()).thenAnswer((_) async => Right(tAssignees));

    await tester.pumpWidget(buildPage());
    await tester.pumpAndSettle();

    expect(find.text('Create Task'), findsWidgets);
    expect(find.byKey(const Key('taskTitleField')), findsOneWidget);
    expect(find.byKey(const Key('taskDescriptionField')), findsOneWidget);
    expect(find.byKey(const Key('taskDueDateField')), findsOneWidget);
    expect(find.byKey(const Key('taskStatusField')), findsOneWidget);
    expect(find.byKey(const Key('taskPriorityField')), findsOneWidget);
    expect(find.byKey(const Key('taskAssigneeField')), findsOneWidget);
    expect(find.byKey(const Key('submitTaskButton')), findsOneWidget);
  });

  testWidgets('validation fails on empty form submission', (tester) async {
    when(() => getAssigneesUseCase()).thenAnswer((_) async => Right(tAssignees));

    await tester.pumpWidget(buildPage());
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('submitTaskButton')));
    await tester.pumpAndSettle();

    expect(find.text('Title is required'), findsOneWidget);
    expect(find.text('Description is required'), findsOneWidget);
  });

  testWidgets('shows loading state when submitting', (tester) async {
    when(() => getAssigneesUseCase()).thenAnswer((_) async => Right(tAssignees));
    final completer = Completer<Either<Failure, Task>>();
    when(() => createTaskUseCase(
          projectId: projectId,
          title: 'Valid Title',
          description: 'Valid Desc',
          status: any(named: 'status'),
          priority: any(named: 'priority'),
          assigneeId: any(named: 'assigneeId'),
          dueDate: any(named: 'dueDate'),
        )).thenAnswer((_) => completer.future);

    await tester.pumpWidget(buildPage());
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('taskTitleField')), 'Valid Title');
    await tester.enterText(find.byKey(const Key('taskDescriptionField')), 'Valid Desc');
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('submitTaskButton')));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('success state flows and pops', (tester) async {
    when(() => getAssigneesUseCase()).thenAnswer((_) async => Right(tAssignees));
    when(() => createTaskUseCase(
          projectId: projectId,
          title: 'Valid Title',
          description: 'Valid Desc',
          status: any(named: 'status'),
          priority: any(named: 'priority'),
          assigneeId: any(named: 'assigneeId'),
          dueDate: any(named: 'dueDate'),
        )).thenAnswer((_) async => Right(tTask));

    await tester.pumpWidget(buildPage());
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('taskTitleField')), 'Valid Title');
    await tester.enterText(find.byKey(const Key('taskDescriptionField')), 'Valid Desc');
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('submitTaskButton')));
    await tester.pumpAndSettle();

    expect(find.text('Task created successfully'), findsOneWidget);
  });

  testWidgets('shows error state when creation fails', (tester) async {
    when(() => getAssigneesUseCase()).thenAnswer((_) async => Right(tAssignees));
    when(() => createTaskUseCase(
          projectId: projectId,
          title: 'Valid Title',
          description: 'Valid Desc',
          status: any(named: 'status'),
          priority: any(named: 'priority'),
          assigneeId: any(named: 'assigneeId'),
          dueDate: any(named: 'dueDate'),
        )).thenAnswer((_) async => const Left(ServerFailure('Connection failed')));

    await tester.pumpWidget(buildPage());
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('taskTitleField')), 'Valid Title');
    await tester.enterText(find.byKey(const Key('taskDescriptionField')), 'Valid Desc');
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('submitTaskButton')));
    await tester.pumpAndSettle();

    expect(find.text('Connection failed'), findsOneWidget);
  });
}
