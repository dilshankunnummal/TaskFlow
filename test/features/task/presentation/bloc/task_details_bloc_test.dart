import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart' hide Task;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:taskflow/core/error/failures.dart';
import 'package:taskflow/features/tasks/domain/entities/task.dart';
import 'package:taskflow/features/tasks/domain/entities/task_assignee.dart';
import 'package:taskflow/features/tasks/domain/entities/task_comment.dart';
import 'package:taskflow/features/tasks/domain/entities/task_details.dart';
import 'package:taskflow/features/tasks/domain/usecases/get_task_details_usecase.dart';
import 'package:taskflow/features/tasks/presentation/bloc/task_details_bloc.dart';
import 'package:taskflow/features/tasks/presentation/bloc/task_details_event.dart';
import 'package:taskflow/features/tasks/presentation/bloc/task_details_state.dart';

class MockGetTaskDetailsUseCase extends Mock implements GetTaskDetailsUseCase {}

void main() {
  late MockGetTaskDetailsUseCase getTaskDetails;

  const taskId = 'task_001';

  final task = Task(
    id: taskId,
    projectId: 'proj_001',
    title: 'Fix login bug',
    description: 'Users report crash on login.',
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
    getTaskDetails = MockGetTaskDetailsUseCase();
  });

  TaskDetailsBloc buildBloc() => TaskDetailsBloc(getTaskDetails);

  group('TaskDetailsBloc', () {
    test('initial state is TaskDetailsInitial', () {
      expect(buildBloc().state, const TaskDetailsInitial());
    });

    // ── LoadTaskDetails ───────────────────────────────────────────────────────

    blocTest<TaskDetailsBloc, TaskDetailsState>(
      'emits [Loading, Success] when LoadTaskDetails succeeds',
      build: () {
        when(() => getTaskDetails(taskId: taskId))
            .thenAnswer((_) async => Right(taskDetails));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const LoadTaskDetails(taskId)),
      expect: () => [
        const TaskDetailsLoading(),
        TaskDetailsSuccess(
          task: task,
          assignee: assignee,
          comments: [comment],
        ),
      ],
    );

    blocTest<TaskDetailsBloc, TaskDetailsState>(
      'emits [Loading, Error] when LoadTaskDetails returns NotFoundFailure',
      build: () {
        when(() => getTaskDetails(taskId: taskId))
            .thenAnswer((_) async => const Left(NotFoundFailure()));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const LoadTaskDetails(taskId)),
      expect: () => [
        const TaskDetailsLoading(),
        const TaskDetailsError('The requested resource was not found.'),
      ],
    );

    blocTest<TaskDetailsBloc, TaskDetailsState>(
      'emits [Loading, Error] when LoadTaskDetails returns UnknownFailure',
      build: () {
        when(() => getTaskDetails(taskId: taskId))
            .thenAnswer((_) async => const Left(UnknownFailure()));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const LoadTaskDetails(taskId)),
      expect: () => [
        const TaskDetailsLoading(),
        const TaskDetailsError('An unexpected error occurred.'),
      ],
    );

    // ── Offline / stale ───────────────────────────────────────────────────────

    blocTest<TaskDetailsBloc, TaskDetailsState>(
      'emits [Loading, Success(isStale)] when offline but cached data exists',
      build: () {
        when(() => getTaskDetails(taskId: taskId)).thenAnswer(
          (_) async =>
              Left(OfflineFailure(taskDetails, 'Offline. Showing cached task details.')),
        );
        return buildBloc();
      },
      act: (bloc) => bloc.add(const LoadTaskDetails(taskId)),
      expect: () => [
        const TaskDetailsLoading(),
        TaskDetailsSuccess(
          task: task,
          assignee: assignee,
          comments: [comment],
          isStale: true,
        ),
      ],
    );

    blocTest<TaskDetailsBloc, TaskDetailsState>(
      'emits [Loading, Error] when offline and no cached data is available',
      build: () {
        when(() => getTaskDetails(taskId: taskId)).thenAnswer(
          (_) async => const Left(OfflineFailure(null)),
        );
        return buildBloc();
      },
      act: (bloc) => bloc.add(const LoadTaskDetails(taskId)),
      expect: () => [
        const TaskDetailsLoading(),
        const TaskDetailsError('You are offline'),
      ],
    );

    // ── RefreshTaskDetails ────────────────────────────────────────────────────

    blocTest<TaskDetailsBloc, TaskDetailsState>(
      'RefreshTaskDetails emits Success without a prior Loading state',
      build: () {
        when(() => getTaskDetails(taskId: taskId))
            .thenAnswer((_) async => Right(taskDetails));
        return buildBloc();
      },
      // Seed with Error so the transition Error → Success is observable
      // (avoids Bloc equality deduplication if seed == result).
      seed: () => const TaskDetailsError('previous error'),
      act: (bloc) => bloc.add(const RefreshTaskDetails(taskId)),
      expect: () => [
        // No TaskDetailsLoading — refresh is silent
        TaskDetailsSuccess(
          task: task,
          assignee: assignee,
          comments: [comment],
        ),
      ],
    );

    blocTest<TaskDetailsBloc, TaskDetailsState>(
      'RefreshTaskDetails emits Error when use case fails',
      build: () {
        when(() => getTaskDetails(taskId: taskId))
            .thenAnswer((_) async => const Left(NotFoundFailure()));
        return buildBloc();
      },
      seed: () => TaskDetailsSuccess(
        task: task,
        assignee: assignee,
        comments: [comment],
      ),
      act: (bloc) => bloc.add(const RefreshTaskDetails(taskId)),
      expect: () => [
        const TaskDetailsError('The requested resource was not found.'),
      ],
    );
  });
}
