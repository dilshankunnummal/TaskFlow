import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:taskflow/core/auth/current_session.dart';
import 'package:taskflow/core/error/failures.dart';
import 'package:taskflow/features/projects/domain/entities/project.dart';
import 'package:taskflow/features/projects/domain/usecases/create_project_usecase.dart';
import 'package:taskflow/features/projects/domain/usecases/delete_project_usecase.dart';
import 'package:taskflow/features/projects/domain/usecases/update_project_usecase.dart';
import 'package:taskflow/features/projects/presentation/bloc/project_form/project_form_bloc.dart';
import 'package:taskflow/features/projects/presentation/bloc/project_form/project_form_event.dart';
import 'package:taskflow/features/projects/presentation/bloc/project_form/project_form_state.dart';

class MockCreateProjectUseCase extends Mock implements CreateProjectUseCase {}

class MockUpdateProjectUseCase extends Mock implements UpdateProjectUseCase {}

class MockDeleteProjectUseCase extends Mock implements DeleteProjectUseCase {}

class MockCurrentSession extends Mock implements CurrentSession {}

void main() {
  late MockCreateProjectUseCase createUseCase;
  late MockUpdateProjectUseCase updateUseCase;
  late MockDeleteProjectUseCase deleteUseCase;
  late MockCurrentSession currentSession;

  const orgId = 'org_a1b2c3';
  const projectId = 'proj_1001';

  final project = Project(
    id: projectId,
    orgId: orgId,
    name: 'Website Relaunch',
    description: 'Redesign the marketing website.',
    status: ProjectStatus.planning,
    taskCount: 0,
    createdAt: DateTime.parse('2026-01-01T09:00:00Z'),
  );

  setUp(() {
    createUseCase = MockCreateProjectUseCase();
    updateUseCase = MockUpdateProjectUseCase();
    deleteUseCase = MockDeleteProjectUseCase();
    currentSession = MockCurrentSession();
    when(() => currentSession.currentOrgId).thenAnswer((_) async => orgId);
  });

  ProjectFormBloc buildBloc() => ProjectFormBloc(createUseCase, updateUseCase, deleteUseCase, currentSession);

  late Completer<Either<Failure, Project>> createCompleter;

  group('ProjectFormBloc', () {
    test('initial state is ProjectFormInitial', () {
      expect(buildBloc().state, const ProjectFormInitial());
    });

    blocTest<ProjectFormBloc, ProjectFormState>(
      'emits ProjectFormLoading before Success when CreateProject resolves',
      build: () {
        createCompleter = Completer<Either<Failure, Project>>();
        when(() => createUseCase(
          orgId: orgId,
          name: project.name,
          description: project.description,
          status: ProjectStatus.planning,
        )).thenAnswer((_) => createCompleter.future);
        return buildBloc();
      },
      act: (bloc) async {
        bloc.add(CreateProject(
          name: project.name,
          description: project.description,
        ));
        await Future<void>.delayed(Duration.zero);
        expect(bloc.state, const ProjectFormLoading());
        createCompleter.complete(Right(project));
      },
      expect: () => [
        const ProjectFormLoading(),
        ProjectFormSuccess(message: 'Project created successfully', project: project),
      ],
    );

    blocTest<ProjectFormBloc, ProjectFormState>(
      'emits [Loading, Success] when CreateProject succeeds',
      build: () {
        when(() => createUseCase(
          orgId: orgId,
          name: project.name,
          description: project.description,
          status: ProjectStatus.planning,
        )).thenAnswer((_) async => Right(project));
        return buildBloc();
      },
      act: (bloc) => bloc.add(CreateProject(
        name: project.name,
        description: project.description,
      )),
      expect: () => [
        const ProjectFormLoading(),
        ProjectFormSuccess(message: 'Project created successfully', project: project),
      ],
    );

    blocTest<ProjectFormBloc, ProjectFormState>(
      'emits [Loading, Error] when CreateProject has no active organization in session',
      build: () {
        when(() => currentSession.currentOrgId).thenAnswer((_) async => null);
        return buildBloc();
      },
      act: (bloc) => bloc.add(CreateProject(
        name: project.name,
        description: project.description,
      )),
      expect: () => [
        const ProjectFormLoading(),
        const ProjectFormError(message: 'No active organization found for this session'),
      ],
      verify: (_) {
        verifyNever(() => createUseCase(
          orgId: any(named: 'orgId'),
          name: any(named: 'name'),
          description: any(named: 'description'),
          status: any(named: 'status'),
        ));
      },
    );

    blocTest<ProjectFormBloc, ProjectFormState>(
      'emits [Loading, Success] when UpdateProject succeeds',
      build: () {
        when(() => updateUseCase(project: project)).thenAnswer((_) async => Right(project));
        return buildBloc();
      },
      act: (bloc) => bloc.add(UpdateProject(project)),
      expect: () => [
        const ProjectFormLoading(),
        ProjectFormSuccess(message: 'Project updated successfully', project: project),
      ],
    );

    blocTest<ProjectFormBloc, ProjectFormState>(
      'emits [Loading, Success] when DeleteProject succeeds',
      build: () {
        when(() => deleteUseCase(projectId: projectId)).thenAnswer((_) async => const Right(unit));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const DeleteProject(projectId)),
      expect: () => [
        const ProjectFormLoading(),
        const ProjectFormSuccess(message: 'Project deleted successfully'),
      ],
    );

    blocTest<ProjectFormBloc, ProjectFormState>(
      'emits [Loading, Error] with validationErrors when CreateProject fails validation',
      build: () {
        when(() => createUseCase(
          orgId: orgId,
          name: '',
          description: project.description,
          status: ProjectStatus.planning,
        )).thenAnswer((_) async => const Left(ValidationFailure('Project name must not be empty')));
        return buildBloc();
      },
      act: (bloc) => bloc.add(CreateProject(
        name: '',
        description: project.description,
      )),
      expect: () => [
        const ProjectFormLoading(),
        const ProjectFormError(validationErrors: ['Project name must not be empty']),
      ],
    );

    blocTest<ProjectFormBloc, ProjectFormState>(
      'emits [Loading, Error] when DeleteProject fails with PermissionFailure',
      build: () {
        when(() => deleteUseCase(projectId: projectId)).thenAnswer((_) async => const Left(PermissionFailure()));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const DeleteProject(projectId)),
      expect: () => [
        const ProjectFormLoading(),
        const ProjectFormError(message: 'You do not have permission to perform this action.'),
      ],
    );

    blocTest<ProjectFormBloc, ProjectFormState>(
      'emits [Loading, Error] when UpdateProject fails with NotFoundFailure',
      build: () {
        when(() => updateUseCase(project: project)).thenAnswer((_) async => const Left(NotFoundFailure()));
        return buildBloc();
      },
      act: (bloc) => bloc.add(UpdateProject(project)),
      expect: () => [
        const ProjectFormLoading(),
        const ProjectFormError(message: 'The requested resource was not found.'),
      ],
    );

    blocTest<ProjectFormBloc, ProjectFormState>(
      'emits [Loading, Error] when CreateProject fails with UnknownFailure',
      build: () {
        when(() => createUseCase(
          orgId: orgId,
          name: project.name,
          description: project.description,
          status: ProjectStatus.planning,
        )).thenAnswer((_) async => const Left(UnknownFailure()));
        return buildBloc();
      },
      act: (bloc) => bloc.add(CreateProject(
        name: project.name,
        description: project.description,
      )),
      expect: () => [
        const ProjectFormLoading(),
        const ProjectFormError(message: 'An unexpected error occurred.'),
      ],
    );
  });
}