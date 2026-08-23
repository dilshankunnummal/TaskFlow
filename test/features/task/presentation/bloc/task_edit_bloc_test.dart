import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart' hide Task;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:taskflow/core/error/failures.dart';
import 'package:taskflow/features/tasks/domain/entities/task.dart';
import 'package:taskflow/features/tasks/domain/entities/task_assignee.dart';
import 'package:taskflow/features/tasks/domain/entities/task_details.dart';
import 'package:taskflow/features/tasks/domain/usecases/get_assignees_usecase.dart';
import 'package:taskflow/features/tasks/domain/usecases/get_task_details_usecase.dart';
import 'package:taskflow/features/tasks/domain/usecases/update_task_usecase.dart';
import 'package:taskflow/features/tasks/presentation/bloc/task_edit_bloc.dart';
import 'package:taskflow/features/tasks/presentation/bloc/task_edit_event.dart';
import 'package:taskflow/features/tasks/presentation/bloc/task_edit_state.dart';

class MockGetTaskDetailsUseCase extends Mock implements GetTaskDetailsUseCase {}

class MockGetAssigneesUseCase extends Mock implements GetAssigneesUseCase {}

class MockUpdateTaskUseCase extends Mock implements UpdateTaskUseCase {}

void main() {
  late MockGetTaskDetailsUseCase getTaskDetails;
  late MockGetAssigneesUseCase getAssignees;
  late MockUpdateTaskUseCase updateTask;

  const taskId = 'task_001';

  final initialTask = Task(
    id: taskId,
    projectId: 'proj_001',
    title: 'Initial Title',
    description: 'Initial Description',
    status: TaskStatus.todo,
    priority: TaskPriority.low,
    assigneeId: 'user_001',
    dueDate: DateTime(2026, 9, 15),
    createdAt: DateTime(2026, 8, 1),
  );

  final updatedTask = Task(
    id: taskId,
    projectId: 'proj_001',
    title: 'Updated Title',
    description: 'Updated Description',
    status: TaskStatus.inProgress,
    priority: TaskPriority.high,
    assigneeId: 'user_001',
    dueDate: DateTime(2026, 9, 20),
    createdAt: DateTime(2026, 8, 1),
  );

  const assignee = TaskAssignee(
    id: 'user_001',
    name: 'Ava Thompson',
    email: 'ava@test.com',
  );

  final taskDetails = TaskDetails(
    task: initialTask,
    assignee: assignee,
    comments: const [],
  );

  setUp(() {
    getTaskDetails = MockGetTaskDetailsUseCase();
    getAssignees = MockGetAssigneesUseCase();
    updateTask = MockUpdateTaskUseCase();
  });

  TaskEditBloc buildBloc() => TaskEditBloc(
        getTaskDetails,
        getAssignees,
        updateTask,
      );

  group('TaskEditBloc', () {
    test('initial state is TaskEditInitial', () {
      expect(buildBloc().state, const TaskEditInitial());
    });

    blocTest<TaskEditBloc, TaskEditState>(
      'emits [TaskEditLoading, TaskEditLoaded] when LoadTaskForEditing succeeds',
      build: () {
        when(() => getAssignees())
            .thenAnswer((_) async => const Right([assignee]));
        when(() => getTaskDetails(taskId: taskId))
            .thenAnswer((_) async => Right(taskDetails));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const LoadTaskForEditing(taskId)),
      expect: () => [
        const TaskEditLoading(task: null, assignees: []),
        TaskEditLoaded(task: initialTask, assignees: const [assignee]),
      ],
    );

    blocTest<TaskEditBloc, TaskEditState>(
      'emits [TaskEditSubmitting, TaskEditSuccess] when UpdateTaskSubmitted succeeds',
      build: () {
        when(() => updateTask(
              id: taskId,
              projectId: 'proj_001',
              title: 'Updated Title',
              description: 'Updated Description',
              status: TaskStatus.inProgress,
              priority: TaskPriority.high,
              assigneeId: 'user_001',
              dueDate: any(named: 'dueDate'),
              createdAt: any(named: 'createdAt'),
            )).thenAnswer((_) async => Right(updatedTask));
        return buildBloc();
      },
      seed: () => TaskEditLoaded(task: initialTask, assignees: const [assignee]),
      act: (bloc) => bloc.add(UpdateTaskSubmitted(
        id: taskId,
        projectId: 'proj_001',
        title: 'Updated Title',
        description: 'Updated Description',
        status: TaskStatus.inProgress,
        priority: TaskPriority.high,
        assigneeId: 'user_001',
        dueDate: DateTime(2026, 9, 20),
        createdAt: DateTime(2026, 8, 1),
      )),
      expect: () => [
        TaskEditSubmitting(task: initialTask, assignees: const [assignee]),
        TaskEditSuccess(updatedTask, assignees: const [assignee]),
      ],
    );

    blocTest<TaskEditBloc, TaskEditState>(
      'emits [TaskEditSubmitting, TaskEditError] when UpdateTaskSubmitted fails with ValidationFailure',
      build: () {
        when(() => updateTask(
              id: taskId,
              projectId: 'proj_001',
              title: '',
              description: 'Description',
              status: TaskStatus.todo,
              priority: TaskPriority.low,
              assigneeId: null,
              dueDate: null,
              createdAt: any(named: 'createdAt'),
            )).thenAnswer((_) async => const Left(ValidationFailure('Title is required')));
        return buildBloc();
      },
      seed: () => TaskEditLoaded(task: initialTask, assignees: const [assignee]),
      act: (bloc) => bloc.add(UpdateTaskSubmitted(
        id: taskId,
        projectId: 'proj_001',
        title: '',
        description: 'Description',
        status: TaskStatus.todo,
        priority: TaskPriority.low,
        assigneeId: null,
        dueDate: null,
        createdAt: DateTime(2026, 8, 1),
      )),
      expect: () => [
        TaskEditSubmitting(task: initialTask, assignees: const [assignee]),
        TaskEditError('Title is required', task: initialTask, assignees: const [assignee]),
      ],
    );

    blocTest<TaskEditBloc, TaskEditState>(
      'emits [TaskEditSubmitting, TaskEditError] on repository failure',
      build: () {
        when(() => updateTask(
              id: taskId,
              projectId: 'proj_001',
              title: 'Title',
              description: 'Description',
              status: TaskStatus.todo,
              priority: TaskPriority.low,
              assigneeId: null,
              dueDate: null,
              createdAt: any(named: 'createdAt'),
            )).thenAnswer((_) async => const Left(UnknownFailure()));
        return buildBloc();
      },
      seed: () => TaskEditLoaded(task: initialTask, assignees: const [assignee]),
      act: (bloc) => bloc.add(UpdateTaskSubmitted(
        id: taskId,
        projectId: 'proj_001',
        title: 'Title',
        description: 'Description',
        status: TaskStatus.todo,
        priority: TaskPriority.low,
        assigneeId: null,
        dueDate: null,
        createdAt: DateTime(2026, 8, 1),
      )),
      expect: () => [
        TaskEditSubmitting(task: initialTask, assignees: const [assignee]),
        TaskEditError('An unexpected error occurred.', task: initialTask, assignees: const [assignee]),
      ],
    );
  });
}
