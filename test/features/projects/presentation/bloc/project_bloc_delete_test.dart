import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:taskflow/core/auth/current_session.dart';
import 'package:taskflow/core/error/failures.dart';
import 'package:taskflow/features/projects/domain/entities/project.dart';
import 'package:taskflow/features/projects/domain/usecases/delete_project_usecase.dart';
import 'package:taskflow/features/projects/domain/usecases/get_projects.dart';
import 'package:taskflow/features/projects/presentation/bloc/projects_bloc.dart';
import 'package:taskflow/features/projects/presentation/bloc/projects_event.dart';
import 'package:taskflow/features/projects/presentation/bloc/projects_state.dart';

class MockGetProjects extends Mock implements GetProjects {}

class MockDeleteProjectUseCase extends Mock implements DeleteProjectUseCase {}

class MockCurrentSession extends Mock implements CurrentSession {}

void main() {
  late MockGetProjects getProjects;
  late MockDeleteProjectUseCase deleteProjectUseCase;
  late MockCurrentSession currentSession;

  final project = Project(
    id: 'proj_1',
    orgId: 'org_1',
    name: 'Atlas',
    description: 'Rebuild the design system',
    status: ProjectStatus.active,
    taskCount: 4,
    createdAt: DateTime(2026, 1, 1),
  );

  ProjectsBloc buildBloc() => ProjectsBloc(getProjects, deleteProjectUseCase, currentSession);

  setUp(() {
    getProjects = MockGetProjects();
    deleteProjectUseCase = MockDeleteProjectUseCase();
    currentSession = MockCurrentSession();

    when(() => currentSession.currentOrgId).thenAnswer((_) async => 'org_1');
    when(() => getProjects(orgId: any(named: 'orgId')))
        .thenAnswer((_) async => Right([project]));
  });

  group('DeleteProject', () {
    blocTest<ProjectsBloc, ProjectsState>(
      'admin delete succeeds and refreshes the list',
      build: () {
        when(() => deleteProjectUseCase(projectId: 'proj_1'))
            .thenAnswer((_) async => const Right(unit));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const DeleteProject('proj_1')),
      expect: () => [
        const ProjectDeleteInProgress('proj_1'),
        const ProjectDeleteSuccess('proj_1'),
        ProjectsSuccess(
          allProjects: [project],
          visibleProjects: [project],
          query: '',
          sortOption: ProjectSortOption.newest,
        ),
      ],
      verify: (_) {
        verify(() => deleteProjectUseCase(projectId: 'proj_1')).called(1);
      },
    );

    blocTest<ProjectsBloc, ProjectsState>(
      'member delete is rejected with a permission failure',
      build: () {
        when(() => deleteProjectUseCase(projectId: 'proj_1'))
            .thenAnswer((_) async => const Left(PermissionFailure()));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const DeleteProject('proj_1')),
      expect: () => [
        const ProjectDeleteInProgress('proj_1'),
        ProjectDeleteFailure('proj_1', const PermissionFailure().message),
        ProjectsSuccess(
          allProjects: [project],
          visibleProjects: [project],
          query: '',
          sortOption: ProjectSortOption.newest,
        ),
      ],
    );

    blocTest<ProjectsBloc, ProjectsState>(
      'deleting a project that no longer exists returns not found',
      build: () {
        when(() => deleteProjectUseCase(projectId: 'proj_missing'))
            .thenAnswer((_) async => const Left(NotFoundFailure()));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const DeleteProject('proj_missing')),
      expect: () => [
        const ProjectDeleteInProgress('proj_missing'),
        ProjectDeleteFailure('proj_missing', const NotFoundFailure().message),
        ProjectsSuccess(
          allProjects: [project],
          visibleProjects: [project],
          query: '',
          sortOption: ProjectSortOption.newest,
        ),
      ],
    );

    blocTest<ProjectsBloc, ProjectsState>(
      'preserves the active search query and sort option across a delete refresh',
      seed: () => ProjectsSuccess(
        allProjects: [project],
        visibleProjects: [project],
        query: 'atlas',
        sortOption: ProjectSortOption.alphabetical,
      ),
      build: () {
        when(() => deleteProjectUseCase(projectId: 'proj_1'))
            .thenAnswer((_) async => const Right(unit));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const DeleteProject('proj_1')),
      expect: () => [
        const ProjectDeleteInProgress('proj_1'),
        const ProjectDeleteSuccess('proj_1'),
        ProjectsSuccess(
          allProjects: [project],
          visibleProjects: [project],
          query: 'atlas',
          sortOption: ProjectSortOption.alphabetical,
        ),
      ],
    );
  });
}