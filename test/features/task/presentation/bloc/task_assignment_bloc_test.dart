import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart' hide Task;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:taskflow/core/error/failures.dart';
import 'package:taskflow/features/tasks/domain/entities/organization_member.dart';
import 'package:taskflow/features/tasks/domain/entities/task.dart';
import 'package:taskflow/features/tasks/domain/usecases/assign_task_usecase.dart';
import 'package:taskflow/features/tasks/domain/usecases/get_organization_members_usecase.dart';
import 'package:taskflow/features/tasks/domain/usecases/unassign_task_usecase.dart';
import 'package:taskflow/features/tasks/presentation/bloc/task_assignment_bloc.dart';
import 'package:taskflow/features/tasks/presentation/bloc/task_assignment_event.dart';
import 'package:taskflow/features/tasks/presentation/bloc/task_assignment_state.dart';

class MockGetOrganizationMembersUseCase extends Mock
    implements GetOrganizationMembersUseCase {}

class MockAssignTaskUseCase extends Mock implements AssignTaskUseCase {}

class MockUnassignTaskUseCase extends Mock implements UnassignTaskUseCase {}

void main() {
  late MockGetOrganizationMembersUseCase getOrganizationMembers;
  late MockAssignTaskUseCase assignTask;
  late MockUnassignTaskUseCase unassignTask;

  const orgId = 'org_a1b2c3';
  const taskId = 'task_001';
  const userId = 'user_001';

  const member = OrganizationMember(
    id: userId,
    name: 'Ava Thompson',
    email: 'ava@test.com',
    role: 'org_admin',
  );

  final task = Task(
    id: taskId,
    projectId: 'proj_001',
    title: 'Title',
    description: 'Desc',
    status: TaskStatus.todo,
    priority: TaskPriority.medium,
    assigneeId: userId,
    dueDate: null,
    createdAt: DateTime(2026, 8, 1),
  );

  setUp(() {
    getOrganizationMembers = MockGetOrganizationMembersUseCase();
    assignTask = MockAssignTaskUseCase();
    unassignTask = MockUnassignTaskUseCase();
  });

  TaskAssignmentBloc buildBloc() => TaskAssignmentBloc(
        getOrganizationMembers,
        assignTask,
        unassignTask,
      );

  group('TaskAssignmentBloc', () {
    test('initial state is TaskAssignmentInitial', () {
      expect(buildBloc().state, const TaskAssignmentInitial());
    });

    blocTest<TaskAssignmentBloc, TaskAssignmentState>(
      'emits [TaskAssignmentLoading, TaskAssignmentLoaded] when LoadOrganizationMembers succeeds',
      build: () {
        when(() => getOrganizationMembers(orgId))
            .thenAnswer((_) async => const Right([member]));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const LoadOrganizationMembers(organizationId: orgId)),
      expect: () => [
        const TaskAssignmentLoading(),
        const TaskAssignmentLoaded(members: [member], currentAssigneeId: null),
      ],
    );

    blocTest<TaskAssignmentBloc, TaskAssignmentState>(
      'emits [TaskAssignmentLoading, TaskAssignmentSuccess] when AssignUserToTask succeeds',
      build: () {
        when(() => assignTask(taskId: taskId, userId: userId))
            .thenAnswer((_) async => Right(task));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const AssignUserToTask(taskId: taskId, userId: userId)),
      expect: () => [
        const TaskAssignmentLoading(),
        TaskAssignmentSuccess(task),
      ],
    );

    blocTest<TaskAssignmentBloc, TaskAssignmentState>(
      'emits [TaskAssignmentLoading, TaskAssignmentSuccess] when RemoveUserFromTask succeeds',
      build: () {
        when(() => unassignTask(taskId)).thenAnswer((_) async => Right(task));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const RemoveUserFromTask(taskId)),
      expect: () => [
        const TaskAssignmentLoading(),
        TaskAssignmentSuccess(task),
      ],
    );

    blocTest<TaskAssignmentBloc, TaskAssignmentState>(
      'emits [TaskAssignmentLoading, TaskAssignmentError] when user does not belong to organization',
      build: () {
        when(() => assignTask(taskId: taskId, userId: userId))
            .thenAnswer((_) async => const Left(InvalidOrganizationFailure()));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const AssignUserToTask(taskId: taskId, userId: userId)),
      expect: () => [
        const TaskAssignmentLoading(),
        const TaskAssignmentError("User does not belong to the task's organization."),
      ],
    );

    blocTest<TaskAssignmentBloc, TaskAssignmentState>(
      'emits [TaskAssignmentLoading, TaskAssignmentError] on repository failure',
      build: () {
        when(() => unassignTask(taskId))
            .thenAnswer((_) async => const Left(UnknownFailure()));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const RemoveUserFromTask(taskId)),
      expect: () => [
        const TaskAssignmentLoading(),
        const TaskAssignmentError('An unexpected error occurred.'),
      ],
    );
  });
}
