import 'package:dartz/dartz.dart' hide Task;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:taskflow/core/theme/app_theme.dart';
import 'package:taskflow/features/tasks/domain/entities/organization_member.dart';
import 'package:taskflow/features/tasks/domain/entities/task.dart';
import 'package:taskflow/features/tasks/domain/entities/task_assignee.dart';
import 'package:taskflow/features/tasks/domain/entities/task_details.dart';
import 'package:taskflow/features/tasks/domain/usecases/assign_task_usecase.dart';
import 'package:taskflow/features/tasks/domain/usecases/delete_task_usecase.dart';
import 'package:taskflow/features/tasks/domain/usecases/get_organization_members_usecase.dart';
import 'package:taskflow/features/tasks/domain/usecases/get_task_details_usecase.dart';
import 'package:taskflow/features/tasks/domain/usecases/unassign_task_usecase.dart';
import 'package:taskflow/features/tasks/presentation/bloc/task_assignment_bloc.dart';
import 'package:taskflow/features/tasks/presentation/bloc/task_delete_bloc.dart';
import 'package:taskflow/features/tasks/presentation/bloc/task_details_bloc.dart';
import 'package:taskflow/features/tasks/presentation/pages/task_details_page.dart';

class MockGetTaskDetailsUseCase extends Mock implements GetTaskDetailsUseCase {}

class MockDeleteTaskUseCase extends Mock implements DeleteTaskUseCase {}

class MockGetOrganizationMembersUseCase extends Mock
    implements GetOrganizationMembersUseCase {}

class MockAssignTaskUseCase extends Mock implements AssignTaskUseCase {}

class MockUnassignTaskUseCase extends Mock implements UnassignTaskUseCase {}

void main() {
  final getIt = GetIt.instance;
  late MockGetTaskDetailsUseCase getTaskDetails;
  late MockDeleteTaskUseCase deleteTask;
  late MockGetOrganizationMembersUseCase getOrganizationMembers;
  late MockAssignTaskUseCase assignTask;
  late MockUnassignTaskUseCase unassignTask;

  const taskId = 'task_001';
  const orgId = 'org_a1b2c3';

  final unassignedTask = Task(
    id: taskId,
    projectId: 'proj_001',
    title: 'Unassigned Task',
    description: 'Needs assignee',
    status: TaskStatus.todo,
    priority: TaskPriority.medium,
    assigneeId: null,
    dueDate: null,
    createdAt: DateTime(2026, 8, 1),
  );

  const assignee = TaskAssignee(
    id: 'user_001',
    name: 'Ava Thompson',
    email: 'ava@test.com',
  );

  final assignedTask = Task(
    id: taskId,
    projectId: 'proj_001',
    title: 'Assigned Task',
    description: 'Has assignee',
    status: TaskStatus.todo,
    priority: TaskPriority.medium,
    assigneeId: assignee.id,
    dueDate: null,
    createdAt: DateTime(2026, 8, 1),
  );

  const orgMember = OrganizationMember(
    id: 'user_001',
    name: 'Ava Thompson',
    email: 'ava@test.com',
    role: 'org_admin',
  );

  setUp(() {
    getTaskDetails = MockGetTaskDetailsUseCase();
    deleteTask = MockDeleteTaskUseCase();
    getOrganizationMembers = MockGetOrganizationMembersUseCase();
    assignTask = MockAssignTaskUseCase();
    unassignTask = MockUnassignTaskUseCase();

    getIt
      ..reset()
      ..registerFactory<GetTaskDetailsUseCase>(() => getTaskDetails)
      ..registerFactory<DeleteTaskUseCase>(() => deleteTask)
      ..registerFactory<GetOrganizationMembersUseCase>(
          () => getOrganizationMembers)
      ..registerFactory<AssignTaskUseCase>(() => assignTask)
      ..registerFactory<UnassignTaskUseCase>(() => unassignTask)
      ..registerFactory<TaskDetailsBloc>(
        () => TaskDetailsBloc(getTaskDetails),
      )
      ..registerFactory<TaskDeleteBloc>(
        () => TaskDeleteBloc(deleteTask),
      )
      ..registerFactory<TaskAssignmentBloc>(
        () => TaskAssignmentBloc(
          getOrganizationMembers,
          assignTask,
          unassignTask,
        ),
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

  testWidgets('displays Assign User button and opens modal for unassigned task',
      (tester) async {
    when(() => getTaskDetails(taskId: taskId)).thenAnswer((_) async =>
        Right(TaskDetails(task: unassignedTask, assignee: null, comments: const [])));
    when(() => getOrganizationMembers(any()))
        .thenAnswer((_) async => const Right([orgMember]));

    await tester.pumpWidget(buildPage());
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('assignUserButton')), findsOneWidget);

    await tester.tap(find.byKey(const Key('assignUserButton')));
    await tester.pumpAndSettle();

    expect(find.text('Assign User'), findsWidgets);
    expect(find.text('Ava Thompson'), findsOneWidget);
  });

  testWidgets('displays Change and Remove buttons for assigned task',
      (tester) async {
    when(() => getTaskDetails(taskId: taskId)).thenAnswer((_) async =>
        Right(TaskDetails(task: assignedTask, assignee: assignee, comments: const [])));
    when(() => getOrganizationMembers(any()))
        .thenAnswer((_) async => const Right([orgMember]));

    await tester.pumpWidget(buildPage());
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('changeAssigneeButton')), findsOneWidget);
    expect(find.byKey(const Key('removeAssigneeButton')), findsOneWidget);
  });
}
