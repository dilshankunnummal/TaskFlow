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
import 'package:taskflow/features/tasks/domain/entities/task_comment.dart';
import 'package:taskflow/features/tasks/domain/entities/task_details.dart';
import 'package:taskflow/features/tasks/domain/usecases/get_task_details_usecase.dart';
import 'package:taskflow/features/tasks/presentation/bloc/task_details_bloc.dart';
import 'package:taskflow/features/tasks/presentation/pages/task_details_page.dart';

class MockGetTaskDetailsUseCase extends Mock implements GetTaskDetailsUseCase {}

void main() {
  final getIt = GetIt.instance;
  late MockGetTaskDetailsUseCase useCase;

  const taskId = 'task_001';

  final task = Task(
    id: taskId,
    projectId: 'proj_001',
    title: 'Fix login bug',
    description: 'Users report crash on login screen.',
    status: TaskStatus.inProgress,
    priority: TaskPriority.high,
    assigneeId: 'user_001',
    dueDate: DateTime(2026, 9, 15),
    createdAt: DateTime(2026, 8, 1),
  );

  const assignee = TaskAssignee(
    id: 'user_001',
    name: 'Ava Thompson',
    email: 'ava@test.com',
  );

  final comment = TaskComment(
    id: 'cmt_001',
    taskId: taskId,
    authorId: 'user_001',
    authorName: 'Ava Thompson',
    body: 'Looking into this now.',
    createdAt: DateTime(2026, 8, 2),
  );

  final taskDetails = TaskDetails(
    task: task,
    assignee: assignee,
    comments: [comment],
  );

  setUp(() {
    useCase = MockGetTaskDetailsUseCase();
    getIt
      ..reset()
      ..registerFactory<GetTaskDetailsUseCase>(() => useCase)
      ..registerFactory<TaskDetailsBloc>(
        () => TaskDetailsBloc(getIt<GetTaskDetailsUseCase>()),
      );
  });

  tearDown(() async {
    await getIt.reset();
  });

  Widget buildPage() {
    return MaterialApp(
      theme: AppTheme.dark(),
      home: const TaskDetailsPage(taskId: taskId),
    );
  }

  testWidgets('shows a loading skeleton while the task is being fetched',
      (tester) async {
    final completer = Completer<Either<Failure, TaskDetails>>();
    when(() => useCase(taskId: taskId)).thenAnswer((_) => completer.future);

    await tester.pumpWidget(buildPage());
    await tester.pump(); // trigger BlocProvider + initial add(LoadTaskDetails)

    // Skeleton cards should be visible, task title should not yet appear.
    expect(find.text('Fix login bug'), findsNothing);
    // The skeleton renders several SkeletonBox widgets.
    expect(find.byType(SingleChildScrollView), findsWidgets);

    completer.complete(Right(taskDetails));
    await tester.pumpAndSettle();
  });

  testWidgets('renders task header and details on success', (tester) async {
    when(() => useCase(taskId: taskId))
        .thenAnswer((_) async => Right(taskDetails));

    await tester.pumpWidget(buildPage());
    await tester.pumpAndSettle();

    expect(find.text('Fix login bug'), findsOneWidget);
    expect(find.text('In Progress'), findsOneWidget);
    expect(find.text('High'), findsOneWidget);
    expect(find.text('Users report crash on login screen.'), findsOneWidget);
  });

  testWidgets('renders assignee name and email on success', (tester) async {
    when(() => useCase(taskId: taskId))
        .thenAnswer((_) async => Right(taskDetails));

    await tester.pumpWidget(buildPage());
    await tester.pumpAndSettle();

    expect(find.text('Ava Thompson'), findsWidgets); // in assignee + comment
    expect(find.text('ava@test.com'), findsOneWidget);
  });

  testWidgets('renders comments on success', (tester) async {
    when(() => useCase(taskId: taskId))
        .thenAnswer((_) async => Right(taskDetails));

    await tester.pumpWidget(buildPage());
    await tester.pumpAndSettle();

    expect(find.text('Looking into this now.'), findsOneWidget);
  });

  testWidgets('renders "Unassigned" when task has no assignee', (tester) async {
    final unassignedTask = Task(
      id: taskId,
      projectId: 'proj_001',
      title: 'Fix login bug',
      description: 'Users report crash on login screen.',
      status: TaskStatus.inProgress,
      priority: TaskPriority.high,
      assigneeId: null,
      dueDate: DateTime(2026, 9, 15),
      createdAt: DateTime(2026, 8, 1),
    );
    final unassignedDetails = TaskDetails(
      task: unassignedTask,
      assignee: null,
      comments: const [],
    );
    when(() => useCase(taskId: taskId))
        .thenAnswer((_) async => Right(unassignedDetails));

    await tester.pumpWidget(buildPage());
    await tester.pumpAndSettle();

    expect(find.text('Unassigned'), findsOneWidget);
  });

  testWidgets('renders "No comments yet" when the task has no comments',
      (tester) async {
    final noCommentDetails = TaskDetails(
      task: task,
      assignee: assignee,
      comments: const [],
    );
    when(() => useCase(taskId: taskId))
        .thenAnswer((_) async => Right(noCommentDetails));

    await tester.pumpWidget(buildPage());
    await tester.pumpAndSettle();

    expect(find.text('No comments yet'), findsOneWidget);
  });

  testWidgets('renders an error state with a Retry button on failure',
      (tester) async {
    when(() => useCase(taskId: taskId)).thenAnswer(
      (_) async => const Left(NotFoundFailure()),
    );

    await tester.pumpWidget(buildPage());
    await tester.pumpAndSettle();

    expect(find.text('The requested resource was not found.'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
  });

  testWidgets('tapping Retry re-triggers the load', (tester) async {
    var callCount = 0;
    when(() => useCase(taskId: taskId)).thenAnswer((_) async {
      callCount++;
      return const Left(UnknownFailure());
    });

    await tester.pumpWidget(buildPage());
    await tester.pumpAndSettle();

    // First call on initial load.
    expect(callCount, 1);

    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();

    // Second call after retry.
    expect(callCount, 2);
  });
}
