import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart' hide Task;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:taskflow/core/error/failures.dart';
import 'package:taskflow/features/tasks/domain/entities/task.dart';
import 'package:taskflow/features/tasks/domain/entities/task_assignee.dart';
import 'package:taskflow/features/tasks/domain/usecases/create_task_usecase.dart';
import 'package:taskflow/features/tasks/domain/usecases/get_assignees_usecase.dart';
import 'package:taskflow/features/tasks/presentation/bloc/task_create_bloc.dart';
import 'package:taskflow/features/tasks/presentation/bloc/task_create_event.dart';
import 'package:taskflow/features/tasks/presentation/bloc/task_create_state.dart';

class MockCreateTaskUseCase extends Mock implements CreateTaskUseCase {}
class MockGetAssigneesUseCase extends Mock implements GetAssigneesUseCase {}

void main() {
  late MockCreateTaskUseCase createTaskUseCase;
  late MockGetAssigneesUseCase getAssigneesUseCase;
  late TaskCreateBloc bloc;

  final tAssignees = [
    const TaskAssignee(id: '1', name: 'User 1', email: 'user1@test.com'),
    const TaskAssignee(id: '2', name: 'User 2', email: 'user2@test.com'),
  ];

  final tTask = Task(
    id: 'task_1',
    projectId: 'proj_1',
    title: 'Test Title',
    description: 'Test Desc',
    status: TaskStatus.todo,
    priority: TaskPriority.medium,
    assigneeId: '1',
    dueDate: DateTime(2027, 1, 1),
    createdAt: DateTime(2026, 8, 1),
  );

  setUp(() {
    createTaskUseCase = MockCreateTaskUseCase();
    getAssigneesUseCase = MockGetAssigneesUseCase();
    bloc = TaskCreateBloc(createTaskUseCase, getAssigneesUseCase);
  });

  tearDown(() {
    bloc.close();
  });

  test('initial state should be TaskCreateInitial with empty assignees', () {
    expect(bloc.state, const TaskCreateInitial(assignees: []));
  });

  group('LoadAssignees', () {
    blocTest<TaskCreateBloc, TaskCreateState>(
      'should emit [TaskCreateInitial] with loaded assignees when successful',
      build: () {
        when(() => getAssigneesUseCase()).thenAnswer((_) async => Right(tAssignees));
        return bloc;
      },
      act: (bloc) => bloc.add(const LoadAssignees()),
      expect: () => [
        TaskCreateInitial(assignees: tAssignees),
      ],
    );

    blocTest<TaskCreateBloc, TaskCreateState>(
      'should emit [TaskCreateError] when loading assignees fails',
      build: () {
        when(() => getAssigneesUseCase()).thenAnswer(
          (_) async => const Left(ServerFailure('Failed to load assignees')),
        );
        return bloc;
      },
      act: (bloc) => bloc.add(const LoadAssignees()),
      expect: () => [
        const TaskCreateError('Failed to load assignees', assignees: []),
      ],
    );
  });

  group('CreateTaskSubmitted', () {
    blocTest<TaskCreateBloc, TaskCreateState>(
      'should emit [TaskCreateLoading, TaskCreateSuccess] when task creation is successful',
      build: () {
        when(() => createTaskUseCase(
              projectId: 'proj_1',
              title: 'Test Title',
              description: 'Test Desc',
              status: TaskStatus.todo,
              priority: TaskPriority.medium,
              assigneeId: '1',
              dueDate: any(named: 'dueDate'),
            )).thenAnswer((_) async => Right(tTask));
        return bloc;
      },
      act: (bloc) => bloc.add(CreateTaskSubmitted(
        projectId: 'proj_1',
        title: 'Test Title',
        description: 'Test Desc',
        status: TaskStatus.todo,
        priority: TaskPriority.medium,
        assigneeId: '1',
        dueDate: DateTime(2027, 1, 1),
      )),
      expect: () => [
        const TaskCreateLoading(assignees: []),
        TaskCreateSuccess(tTask, assignees: []),
      ],
    );

    blocTest<TaskCreateBloc, TaskCreateState>(
      'should emit [TaskCreateLoading, TaskCreateError] when validation fails',
      build: () {
        when(() => createTaskUseCase(
              projectId: 'proj_1',
              title: '',
              description: 'Test Desc',
              status: TaskStatus.todo,
              priority: TaskPriority.medium,
              assigneeId: '1',
              dueDate: any(named: 'dueDate'),
            )).thenAnswer((_) async => const Left(ValidationFailure('Task title must not be empty')));
        return bloc;
      },
      act: (bloc) => bloc.add(CreateTaskSubmitted(
        projectId: 'proj_1',
        title: '',
        description: 'Test Desc',
        status: TaskStatus.todo,
        priority: TaskPriority.medium,
        assigneeId: '1',
        dueDate: DateTime(2027, 1, 1),
      )),
      expect: () => [
        const TaskCreateLoading(assignees: []),
        const TaskCreateError('Task title must not be empty', assignees: []),
      ],
    );

    blocTest<TaskCreateBloc, TaskCreateState>(
      'should emit [TaskCreateLoading, TaskCreateError] when repository fails',
      build: () {
        when(() => createTaskUseCase(
              projectId: 'proj_1',
              title: 'Test Title',
              description: 'Test Desc',
              status: TaskStatus.todo,
              priority: TaskPriority.medium,
              assigneeId: '1',
              dueDate: any(named: 'dueDate'),
            )).thenAnswer((_) async => const Left(ServerFailure('Connection error')));
        return bloc;
      },
      act: (bloc) => bloc.add(CreateTaskSubmitted(
        projectId: 'proj_1',
        title: 'Test Title',
        description: 'Test Desc',
        status: TaskStatus.todo,
        priority: TaskPriority.medium,
        assigneeId: '1',
        dueDate: DateTime(2027, 1, 1),
      )),
      expect: () => [
        const TaskCreateLoading(assignees: []),
        const TaskCreateError('Connection error', assignees: []),
      ],
    );
  });
}
