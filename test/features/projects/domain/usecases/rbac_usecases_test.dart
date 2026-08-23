import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:taskflow/core/auth/current_session.dart';
import 'package:taskflow/core/error/failures.dart';
import 'package:taskflow/core/utils/id_generator.dart';
import 'package:taskflow/features/projects/domain/entities/project.dart';
import 'package:taskflow/features/projects/domain/repositories/projects_repository.dart';
import 'package:taskflow/features/projects/domain/usecases/create_project_usecase.dart';
import 'package:taskflow/features/projects/domain/usecases/delete_project_usecase.dart';
import 'package:taskflow/features/projects/domain/usecases/update_project_usecase.dart';
import 'package:taskflow/features/tasks/domain/repositories/task_repository.dart';
import 'package:taskflow/features/tasks/domain/usecases/delete_task_usecase.dart';
import 'package:taskflow/features/tasks/domain/usecases/get_organization_members_usecase.dart';

class MockProjectsRepository extends Mock implements ProjectsRepository {}

class MockTaskRepository extends Mock implements TaskRepository {}

class MockCurrentSession extends Mock implements CurrentSession {}

class MockIdGenerator extends Mock implements IdGenerator {}

void main() {
  late MockProjectsRepository projectsRepository;
  late MockTaskRepository taskRepository;
  late MockCurrentSession currentSession;
  late MockIdGenerator idGenerator;

  late CreateProjectUseCase createProjectUseCase;
  late UpdateProjectUseCase updateProjectUseCase;
  late DeleteProjectUseCase deleteProjectUseCase;
  late GetOrganizationMembersUseCase getOrganizationMembersUseCase;
  late DeleteTaskUseCase deleteTaskUseCase;

  const orgId = 'org_a1b2c3';
  const projectId = 'proj_1001';
  const taskId = 'task_1001';

  final project = Project(
    id: projectId,
    orgId: orgId,
    name: 'New Platform',
    description: 'Build core framework',
    status: ProjectStatus.planning,
    taskCount: 0,
    createdAt: DateTime.parse('2026-01-01T09:00:00Z'),
  );

  setUp(() {
    projectsRepository = MockProjectsRepository();
    taskRepository = MockTaskRepository();
    currentSession = MockCurrentSession();
    idGenerator = MockIdGenerator();

    when(() => idGenerator.generate()).thenReturn(projectId);

    createProjectUseCase =
        CreateProjectUseCase(projectsRepository, idGenerator, currentSession);
    updateProjectUseCase =
        UpdateProjectUseCase(projectsRepository, currentSession);
    deleteProjectUseCase =
        DeleteProjectUseCase(projectsRepository, currentSession);
    getOrganizationMembersUseCase =
        GetOrganizationMembersUseCase(taskRepository, currentSession);
    deleteTaskUseCase = DeleteTaskUseCase(taskRepository, currentSession);
  });

  group('RBAC UseCases - org_admin allowed actions', () {
    setUp(() {
      when(() => currentSession.currentUserRole)
          .thenAnswer((_) async => 'org_admin');
    });

    test('CreateProjectUseCase allows org_admin to create project', () async {
      when(() => projectsRepository.createProject(project: any(named: 'project')))
          .thenAnswer((_) async => Right(project));

      final result = await createProjectUseCase(
        orgId: orgId,
        name: project.name,
        description: project.description,
      );

      expect(result.isRight(), isTrue);
    });

    test('UpdateProjectUseCase allows org_admin to edit project', () async {
      when(() => projectsRepository.updateProject(project: any(named: 'project')))
          .thenAnswer((_) async => Right(project));

      final result = await updateProjectUseCase(project: project);

      expect(result.isRight(), isTrue);
    });

    test('DeleteProjectUseCase allows org_admin to delete project', () async {
      when(() => projectsRepository.deleteProject(projectId: projectId))
          .thenAnswer((_) async => const Right(unit));

      final result = await deleteProjectUseCase(projectId: projectId);

      expect(result.isRight(), isTrue);
    });

    test('GetOrganizationMembersUseCase allows org_admin to manage members',
        () async {
      when(() => taskRepository.getOrganizationMembers(orgId))
          .thenAnswer((_) async => const Right([]));

      final result = await getOrganizationMembersUseCase(orgId);

      expect(result.isRight(), isTrue);
    });

    test('DeleteTaskUseCase allows org_admin to delete task', () async {
      when(() => taskRepository.deleteTask(taskId))
          .thenAnswer((_) async => const Right(unit));

      final result = await deleteTaskUseCase(taskId);

      expect(result.isRight(), isTrue);
    });
  });

  group('RBAC UseCases - member restricted actions', () {
    setUp(() {
      when(() => currentSession.currentUserRole)
          .thenAnswer((_) async => 'member');
    });

    test('CreateProjectUseCase rejects member with UnauthorizedFailure',
        () async {
      final result = await createProjectUseCase(
        orgId: orgId,
        name: project.name,
        description: project.description,
      );

      expect(result, isA<Left>());
      result.fold(
        (failure) => expect(failure, isA<UnauthorizedFailure>()),
        (_) => fail('Should not succeed'),
      );
    });

    test('UpdateProjectUseCase rejects member with UnauthorizedFailure',
        () async {
      final result = await updateProjectUseCase(project: project);

      expect(result, isA<Left>());
      result.fold(
        (failure) => expect(failure, isA<UnauthorizedFailure>()),
        (_) => fail('Should not succeed'),
      );
    });

    test('DeleteProjectUseCase rejects member with UnauthorizedFailure',
        () async {
      final result = await deleteProjectUseCase(projectId: projectId);

      expect(result, isA<Left>());
      result.fold(
        (failure) => expect(failure, isA<UnauthorizedFailure>()),
        (_) => fail('Should not succeed'),
      );
    });

    test(
        'GetOrganizationMembersUseCase rejects member with UnauthorizedFailure',
        () async {
      final result = await getOrganizationMembersUseCase(orgId);

      expect(result, isA<Left>());
      result.fold(
        (failure) => expect(failure, isA<UnauthorizedFailure>()),
        (_) => fail('Should not succeed'),
      );
    });

    test('DeleteTaskUseCase rejects member with UnauthorizedFailure',
        () async {
      final result = await deleteTaskUseCase(taskId);

      expect(result, isA<Left>());
      result.fold(
        (failure) => expect(failure, isA<UnauthorizedFailure>()),
        (_) => fail('Should not succeed'),
      );
    });
  });
}
