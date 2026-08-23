import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart' hide Task;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:taskflow/core/error/failures.dart';
import 'package:taskflow/features/tasks/domain/entities/task.dart';
import 'package:taskflow/features/tasks/domain/repositories/task_repository.dart';
import 'package:taskflow/features/tasks/domain/usecases/get_project_tasks_usecase.dart';
import 'package:taskflow/features/tasks/presentation/bloc/task_filter.dart';
import 'package:taskflow/features/tasks/presentation/bloc/task_list_bloc.dart';
import 'package:taskflow/features/tasks/presentation/bloc/task_list_event.dart';
import 'package:taskflow/features/tasks/presentation/bloc/task_list_state.dart';

class MockGetProjectTasksUseCase extends Mock implements GetProjectTasksUseCase {}

class MockTaskRepository extends Mock implements TaskRepository {}

void main() {
  late MockGetProjectTasksUseCase getProjectTasks;
  late MockTaskRepository taskRepository;

  const projectId = 'proj_1';

  final task1 = Task(
    id: 't1',
    projectId: projectId,
    title: 'Design review',
    description: 'Review the new bento layout',
    status: TaskStatus.todo,
    priority: TaskPriority.high,
    assigneeId: 'user_1',
    dueDate: DateTime(2026, 9, 1),
    createdAt: DateTime(2026, 8, 1),
  );

  final task2 = Task(
    id: 't2',
    projectId: projectId,
    title: 'Fix login bug',
    description: 'Users report a crash on login',
    status: TaskStatus.inProgress,
    priority: TaskPriority.low,
    assigneeId: 'user_2',
    dueDate: DateTime(2026, 9, 10),
    createdAt: DateTime(2026, 8, 2),
  );

  final task3 = Task(
    id: 't3',
    projectId: projectId,
    title: 'Write onboarding docs',
    description: 'New hire onboarding guide',
    status: TaskStatus.done,
    priority: TaskPriority.urgent,
    assigneeId: null,
    dueDate: null,
    createdAt: DateTime(2026, 8, 3),
  );

  final task4 = Task(
    id: 't4',
    projectId: projectId,
    title: 'Update API docs',
    description: 'Document the new tasks endpoint',
    status: TaskStatus.review,
    priority: TaskPriority.medium,
    assigneeId: 'user_1',
    dueDate: DateTime(2026, 9, 20),
    createdAt: DateTime(2026, 8, 4),
  );

  final allTasks = [task1, task2, task3, task4];

  setUp(() {
    getProjectTasks = MockGetProjectTasksUseCase();
    taskRepository = MockTaskRepository();
  });

  TaskListBloc buildBloc() => TaskListBloc(getProjectTasks, taskRepository);

  TaskListSuccess baseSuccessState() => TaskListSuccess(allTasks: allTasks, tasks: allTasks);

  group('TaskListBloc - load/refresh (regression)', () {
    test('initial state is TaskListInitial', () {
      expect(buildBloc().state, const TaskListInitial());
    });

    blocTest<TaskListBloc, TaskListState>(
      'emits [Loading, Success] with allTasks == tasks and a default filter on load',
      build: () {
        when(() => getProjectTasks(projectId: projectId)).thenAnswer((_) async => Right(allTasks));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const LoadTasks(projectId)),
      expect: () => [
        const TaskListLoading(),
        TaskListSuccess(allTasks: allTasks, tasks: allTasks),
      ],
    );

    blocTest<TaskListBloc, TaskListState>(
      'emits [Loading, Empty] when the project has no tasks',
      build: () {
        when(() => getProjectTasks(projectId: projectId)).thenAnswer((_) async => const Right([]));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const LoadTasks(projectId)),
      expect: () => [const TaskListLoading(), const TaskListEmpty()],
    );

    blocTest<TaskListBloc, TaskListState>(
      'emits [Loading, Error] when the use case fails',
      build: () {
        when(() => getProjectTasks(projectId: projectId)).thenAnswer((_) async => const Left(NotFoundFailure()));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const LoadTasks(projectId)),
      expect: () => [
        const TaskListLoading(),
        const TaskListError('The requested resource was not found.'),
      ],
    );
  });

  group('TaskListBloc - FilterTasks', () {
    blocTest<TaskListBloc, TaskListState>(
      'filters by a single status',
      build: buildBloc,
      seed: baseSuccessState,
      act: (bloc) => bloc.add(const FilterTasks(TaskFilter(statuses: {TaskStatus.todo}))),
      expect: () => [
        TaskListSuccess(
          allTasks: allTasks,
          tasks: [task1],
          filter: const TaskFilter(statuses: {TaskStatus.todo}),
        ),
      ],
    );

    blocTest<TaskListBloc, TaskListState>(
      'filters by a single priority',
      build: buildBloc,
      seed: baseSuccessState,
      act: (bloc) => bloc.add(const FilterTasks(TaskFilter(priorities: {TaskPriority.urgent}))),
      expect: () => [
        TaskListSuccess(
          allTasks: allTasks,
          tasks: [task3],
          filter: const TaskFilter(priorities: {TaskPriority.urgent}),
        ),
      ],
    );

    blocTest<TaskListBloc, TaskListState>(
      'filters by assignee, excluding unassigned tasks',
      build: buildBloc,
      seed: baseSuccessState,
      act: (bloc) => bloc.add(const FilterTasks(TaskFilter(assigneeIds: {'user_1'}))),
      expect: () => [
        TaskListSuccess(
          allTasks: allTasks,
          tasks: [task1, task4],
          filter: const TaskFilter(assigneeIds: {'user_1'}),
        ),
      ],
    );

    blocTest<TaskListBloc, TaskListState>(
      'filters by due date range, excluding tasks with no due date',
      build: buildBloc,
      seed: baseSuccessState,
      act: (bloc) => bloc.add(FilterTasks(
        TaskFilter(dueDateRange: TaskDueDateRange(start: DateTime(2026, 9, 5), end: DateTime(2026, 9, 15))),
      )),
      expect: () => [
        TaskListSuccess(
          allTasks: allTasks,
          tasks: [task2],
          filter: TaskFilter(dueDateRange: TaskDueDateRange(start: DateTime(2026, 9, 5), end: DateTime(2026, 9, 15))),
        ),
      ],
    );

    blocTest<TaskListBloc, TaskListState>(
      'combines status and priority filters (AND semantics)',
      build: buildBloc,
      seed: baseSuccessState,
      act: (bloc) => bloc.add(const FilterTasks(
        TaskFilter(statuses: {TaskStatus.inProgress}, priorities: {TaskPriority.low}),
      )),
      expect: () => [
        TaskListSuccess(
          allTasks: allTasks,
          tasks: [task2],
          filter: const TaskFilter(statuses: {TaskStatus.inProgress}, priorities: {TaskPriority.low}),
        ),
      ],
    );

    blocTest<TaskListBloc, TaskListState>(
      'combines all four filter dimensions and yields the single matching task',
      build: buildBloc,
      seed: baseSuccessState,
      act: (bloc) => bloc.add(FilterTasks(TaskFilter(
        statuses: {TaskStatus.review},
        priorities: {TaskPriority.medium},
        assigneeIds: {'user_1'},
        dueDateRange: TaskDueDateRange(start: DateTime(2026, 9, 15), end: DateTime(2026, 9, 25)),
      ))),
      expect: () => [
        TaskListSuccess(
          allTasks: allTasks,
          tasks: [task4],
          filter: TaskFilter(
            statuses: {TaskStatus.review},
            priorities: {TaskPriority.medium},
            assigneeIds: {'user_1'},
            dueDateRange: TaskDueDateRange(start: DateTime(2026, 9, 15), end: DateTime(2026, 9, 25)),
          ),
        ),
      ],
    );

    blocTest<TaskListBloc, TaskListState>(
      'yields an empty visible list (still Success, not Empty) when nothing matches',
      build: buildBloc,
      seed: baseSuccessState,
      act: (bloc) => bloc.add(const FilterTasks(TaskFilter(statuses: {TaskStatus.done}, priorities: {TaskPriority.low}))),
      expect: () => [
        TaskListSuccess(
          allTasks: allTasks,
          tasks: const [],
          filter: const TaskFilter(statuses: {TaskStatus.done}, priorities: {TaskPriority.low}),
        ),
      ],
    );

    blocTest<TaskListBloc, TaskListState>(
      'clearing the filter restores the full task list',
      build: buildBloc,
      seed: () => TaskListSuccess(
        allTasks: allTasks,
        tasks: [task1],
        filter: const TaskFilter(statuses: {TaskStatus.todo}),
      ),
      act: (bloc) => bloc.add(const FilterTasks(TaskFilter())),
      expect: () => [
        TaskListSuccess(allTasks: allTasks, tasks: allTasks),
      ],
    );

    blocTest<TaskListBloc, TaskListState>(
      'does nothing when the bloc is not in a success state',
      build: buildBloc,
      act: (bloc) => bloc.add(const FilterTasks(TaskFilter(statuses: {TaskStatus.todo}))),
      expect: () => <TaskListState>[],
    );
  });

  group('TaskListBloc - SearchTasks', () {
    blocTest<TaskListBloc, TaskListState>(
      'searches by title, case-insensitively',
      build: buildBloc,
      seed: baseSuccessState,
      act: (bloc) => bloc.add(const SearchTasks('docs')),
      expect: () => [
        TaskListSuccess(allTasks: allTasks, tasks: [task3, task4], query: 'docs'),
      ],
    );

    blocTest<TaskListBloc, TaskListState>(
      'combines search with an active filter',
      build: buildBloc,
      seed: () => TaskListSuccess(
        allTasks: allTasks,
        tasks: [task3, task4],
        filter: const TaskFilter(),
        query: '',
      ),
      act: (bloc) {
        bloc.add(const FilterTasks(TaskFilter(assigneeIds: {'user_1'})));
        bloc.add(const SearchTasks('docs'));
      },
      expect: () => [
        TaskListSuccess(
          allTasks: allTasks,
          tasks: [task4],
          filter: const TaskFilter(assigneeIds: {'user_1'}),
        ),
        TaskListSuccess(
          allTasks: allTasks,
          tasks: [task4],
          filter: const TaskFilter(assigneeIds: {'user_1'}),
          query: 'docs',
        ),
      ],
    );

    blocTest<TaskListBloc, TaskListState>(
      'clearing the search query restores the filtered set',
      build: buildBloc,
      seed: () => TaskListSuccess(
        allTasks: allTasks,
        tasks: [task4],
        query: 'update',
      ),
      act: (bloc) => bloc.add(const SearchTasks('')),
      expect: () => [
        TaskListSuccess(allTasks: allTasks, tasks: allTasks),
      ],
    );
  });

  group('TaskListBloc - RefreshTasks preserves filter and search', () {
    blocTest<TaskListBloc, TaskListState>(
      'reapplies the active filter and query after a refresh',
      build: () {
        when(() => taskRepository.refreshTasks(projectId: projectId)).thenAnswer((_) async => Right(allTasks));
        return buildBloc();
      },
      seed: () => TaskListSuccess(
        allTasks: allTasks,
        tasks: [task1],
        filter: const TaskFilter(statuses: {TaskStatus.todo}),
      ),
      act: (bloc) => bloc.add(const RefreshTasks(projectId)),
      expect: () => [
        TaskListSuccess(
          allTasks: allTasks,
          tasks: [task1],
          filter: const TaskFilter(statuses: {TaskStatus.todo}),
        ),
      ],
      verify: (_) {
        verify(() => taskRepository.refreshTasks(projectId: projectId)).called(1);
      },
    );

    blocTest<TaskListBloc, TaskListState>(
      'refresh with no prior state uses a default filter and empty query',
      build: () {
        when(() => taskRepository.refreshTasks(projectId: projectId)).thenAnswer((_) async => Right(allTasks));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const RefreshTasks(projectId)),
      expect: () => [
        TaskListSuccess(allTasks: allTasks, tasks: allTasks),
      ],
    );
  });
}