import 'package:dartz/dartz.dart' hide Task;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:taskflow/core/error/failures.dart';
import 'package:taskflow/core/theme/app_theme.dart';
import 'package:taskflow/features/tasks/domain/entities/task.dart';
import 'package:taskflow/features/tasks/domain/entities/task_assignee.dart';
import 'package:taskflow/features/tasks/domain/entities/task_details.dart';
import 'package:taskflow/features/tasks/domain/usecases/get_assignees_usecase.dart';
import 'package:taskflow/features/tasks/domain/usecases/get_task_details_usecase.dart';
import 'package:taskflow/features/tasks/domain/usecases/update_task_usecase.dart';
import 'package:taskflow/features/tasks/presentation/bloc/task_edit_bloc.dart';
import 'package:taskflow/features/tasks/presentation/pages/task_edit_page.dart';

class MockGetTaskDetailsUseCase extends Mock implements GetTaskDetailsUseCase {}

class MockGetAssigneesUseCase extends Mock implements GetAssigneesUseCase {}

class MockUpdateTaskUseCase extends Mock implements UpdateTaskUseCase {}

void main() {
  final getIt = GetIt.instance;
  late MockGetTaskDetailsUseCase getTaskDetails;
  late MockGetAssigneesUseCase getAssignees;
  late MockUpdateTaskUseCase updateTask;

  const taskId = 'task_001';

  final initialTask = Task(
    id: taskId,
    projectId: 'proj_001',
    title: 'Original Title',
    description: 'Original Description',
    status: TaskStatus.todo,
    priority: TaskPriority.low,
    assigneeId: null,
    dueDate: null,
    createdAt: DateTime(2026, 8, 1),
  );

  const assignee = TaskAssignee(
    id: 'user_001',
    name: 'Ava Thompson',
    email: 'ava@test.com',
  );

  final taskDetails = TaskDetails(
    task: initialTask,
    assignee: null,
    comments: const [],
  );

  setUp(() {
    getTaskDetails = MockGetTaskDetailsUseCase();
    getAssignees = MockGetAssigneesUseCase();
    updateTask = MockUpdateTaskUseCase();

    getIt
      ..reset()
      ..registerFactory<GetTaskDetailsUseCase>(() => getTaskDetails)
      ..registerFactory<GetAssigneesUseCase>(() => getAssignees)
      ..registerFactory<UpdateTaskUseCase>(() => updateTask)
      ..registerFactory<TaskEditBloc>(
        () => TaskEditBloc(getTaskDetails, getAssignees, updateTask),
      );
  });

  tearDown(() async {
    await getIt.reset();
  });

  Widget buildPage() {
    return MaterialApp(
      theme: AppTheme.dark(),
      home: const TaskEditPage(taskId: taskId),
    );
  }

  testWidgets('displays preloaded task values on load success', (tester) async {
    when(() => getAssignees()).thenAnswer((_) async => const Right([assignee]));
    when(() => getTaskDetails(taskId: taskId))
        .thenAnswer((_) async => Right(taskDetails));

    await tester.pumpWidget(buildPage());
    await tester.pumpAndSettle();

    expect(find.text('Original Title'), findsOneWidget);
    expect(find.text('Original Description'), findsOneWidget);
    expect(find.text('Update Task'), findsOneWidget);
  });

  testWidgets('shows validation error when title is empty', (tester) async {
    when(() => getAssignees()).thenAnswer((_) async => const Right([assignee]));
    when(() => getTaskDetails(taskId: taskId))
        .thenAnswer((_) async => Right(taskDetails));

    await tester.pumpWidget(buildPage());
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('taskTitleField')), '');
    await tester.tap(find.byKey(const Key('submitTaskButton')));
    await tester.pumpAndSettle();

    expect(find.text('Title is required'), findsOneWidget);
  });

  testWidgets('renders error state widget on load failure', (tester) async {
    when(() => getAssignees()).thenAnswer((_) async => const Right([]));
    when(() => getTaskDetails(taskId: taskId))
        .thenAnswer((_) async => const Left(NotFoundFailure()));

    await tester.pumpWidget(buildPage());
    await tester.pumpAndSettle();

    expect(find.text('The requested resource was not found.'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
  });
}
