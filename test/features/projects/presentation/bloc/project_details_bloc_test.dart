import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:taskflow/core/error/failures.dart';
import 'package:taskflow/features/projects/domain/entities/project.dart';
import 'package:taskflow/features/projects/domain/entities/project_details.dart';
import 'package:taskflow/features/projects/domain/entities/project_task.dart';
import 'package:taskflow/features/projects/domain/usecases/delete_project_usecase.dart';
import 'package:taskflow/features/projects/domain/usecases/get_project_details_usecase.dart';
import 'package:taskflow/features/projects/presentation/bloc/project_details_bloc.dart';
import 'package:taskflow/features/projects/presentation/bloc/project_details_event.dart';
import 'package:taskflow/features/projects/presentation/bloc/project_details_state.dart';

class MockGetProjectDetailsUseCase extends Mock implements GetProjectDetailsUseCase {}

class MockDeleteProjectUseCase extends Mock implements DeleteProjectUseCase {}

void main() {
  late MockGetProjectDetailsUseCase useCase;
  late MockDeleteProjectUseCase deleteUseCase;

  const projectId = 'proj_1001';

  final project = Project(
    id: projectId,
    orgId: 'org_a1b2c3',
    name: 'Website Relaunch',
    description: 'Redesign the marketing website.',
    status: ProjectStatus.active,
    taskCount: 2,
    createdAt: DateTime.parse('2025-12-01T10:00:00Z'),
  );

  final tasks = [
    ProjectTask(
      id: 'task_2001',
      projectId: projectId,
      title: 'Set up design tokens',
      description: 'Define color and spacing tokens.',
      status: ProjectTaskStatus.done,
      priority: ProjectTaskPriority.medium,
      assigneeId: 'user_002',
      dueDate: DateTime.parse('2026-01-05'),
      createdAt: DateTime.parse('2025-12-02T09:00:00Z'),
    ),
    ProjectTask(
      id: 'task_2002',
      projectId: projectId,
      title: 'Build responsive nav',
      description: 'Implement header navigation.',
      status: ProjectTaskStatus.inProgress,
      priority: ProjectTaskPriority.high,
      assigneeId: 'user_003',
      dueDate: DateTime.parse('2026-01-20'),
      createdAt: DateTime.parse('2025-12-05T09:00:00Z'),
    ),
  ];

  final populatedDetails = ProjectDetails(project: project, tasks: tasks);
  final emptyDetails = ProjectDetails(project: project, tasks: const []);

  final populatedSummary = TaskSummary.fromTasks(tasks);

  setUp(() {
    useCase = MockGetProjectDetailsUseCase();
    deleteUseCase = MockDeleteProjectUseCase();
  });

  ProjectDetailsBloc buildBloc() => ProjectDetailsBloc(useCase, deleteUseCase);

  group('ProjectDetailsBloc', () {
    test('initial state is ProjectDetailsInitial', () {
      expect(buildBloc().state, const ProjectDetailsInitial());
    });

    blocTest<ProjectDetailsBloc, ProjectDetailsState>(
      'emits [Loading, Success] when the project has tasks',
      build: () {
        when(() => useCase(projectId: projectId)).thenAnswer((_) async => Right(populatedDetails));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const LoadProjectDetails(projectId)),
      expect: () => [
        const ProjectDetailsLoading(),
        ProjectDetailsSuccess(
          project: project,
          tasks: tasks,
          taskSummary: populatedSummary,
        ),
      ],
    );

    blocTest<ProjectDetailsBloc, ProjectDetailsState>(
      'emits [Loading, Empty] when the project has no tasks',
      build: () {
        when(() => useCase(projectId: projectId)).thenAnswer((_) async => Right(emptyDetails));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const LoadProjectDetails(projectId)),
      expect: () => [
        const ProjectDetailsLoading(),
        ProjectDetailsEmpty(project: project),
      ],
    );

    blocTest<ProjectDetailsBloc, ProjectDetailsState>(
      'emits [Loading, Error] when the use case returns a failure',
      build: () {
        when(() => useCase(projectId: projectId)).thenAnswer((_) async => const Left(NotFoundFailure()));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const LoadProjectDetails(projectId)),
      expect: () => [
        const ProjectDetailsLoading(),
        const ProjectDetailsError('The requested resource was not found.'),
      ],
    );

    blocTest<ProjectDetailsBloc, ProjectDetailsState>(
      'emits Error with no cached fallback when offline and nothing has succeeded yet',
      build: () {
        when(() => useCase(projectId: projectId)).thenAnswer((_) async => const Left(OfflineFailure(null)));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const LoadProjectDetails(projectId)),
      expect: () => [
        const ProjectDetailsLoading(),
        const ProjectDetailsError('You are offline'),
      ],
    );

    blocTest<ProjectDetailsBloc, ProjectDetailsState>(
      'refetches without a loading state and emits Success again on RefreshProjectDetails',
      build: () {
        when(() => useCase(projectId: projectId)).thenAnswer((_) async => Right(populatedDetails));
        return buildBloc();
      },
      seed: () => ProjectDetailsSuccess(
        project: project,
        tasks: tasks,
        taskSummary: populatedSummary,
      ),
      act: (bloc) => bloc.add(const RefreshProjectDetails(projectId)),
      expect: () => [
        ProjectDetailsSuccess(
          project: project,
          tasks: tasks,
          taskSummary: populatedSummary,
        ),
      ],
    );

    blocTest<ProjectDetailsBloc, ProjectDetailsState>(
      'falls back to the last successful data marked stale when a refresh goes offline',
      build: () {
        var callCount = 0;
        when(() => useCase(projectId: projectId)).thenAnswer((_) async {
          callCount += 1;
          if (callCount == 1) {
            return Right(populatedDetails);
          }
          return const Left(OfflineFailure(null));
        });
        return buildBloc();
      },
      act: (bloc) async {
        bloc.add(const LoadProjectDetails(projectId));
        await Future<void>.delayed(Duration.zero);
        bloc.add(const RefreshProjectDetails(projectId));
      },
      expect: () => [
        const ProjectDetailsLoading(),
        ProjectDetailsSuccess(
          project: project,
          tasks: tasks,
          taskSummary: populatedSummary,
        ),
        ProjectDetailsSuccess(
          project: project,
          tasks: tasks,
          taskSummary: populatedSummary,
          isStale: true,
        ),
      ],
    );

    blocTest<ProjectDetailsBloc, ProjectDetailsState>(
      'emits [DeleteInProgress, DeleteSuccess] when delete succeeds',
      build: () {
        when(() => deleteUseCase(projectId: projectId))
            .thenAnswer((_) async => const Right(unit));
        return buildBloc();
      },
      seed: () => ProjectDetailsSuccess(
        project: project,
        tasks: tasks,
        taskSummary: populatedSummary,
      ),
      act: (bloc) => bloc.add(const DeleteProjectDetails(projectId)),
      expect: () => [
        const ProjectDetailsDeleteInProgress(),
        const ProjectDetailsDeleteSuccess(),
      ],
    );

    blocTest<ProjectDetailsBloc, ProjectDetailsState>(
      'emits [DeleteInProgress, DeleteFailure] when the member lacks permission',
      build: () {
        when(() => deleteUseCase(projectId: projectId))
            .thenAnswer((_) async => const Left(PermissionFailure()));
        return buildBloc();
      },
      seed: () => ProjectDetailsSuccess(
        project: project,
        tasks: tasks,
        taskSummary: populatedSummary,
      ),
      act: (bloc) => bloc.add(const DeleteProjectDetails(projectId)),
      expect: () => [
        const ProjectDetailsDeleteInProgress(),
        const ProjectDetailsDeleteFailure('You do not have permission to perform this action.'),
      ],
    );

    blocTest<ProjectDetailsBloc, ProjectDetailsState>(
      'emits [DeleteInProgress, DeleteFailure] when delete fails for another reason',
      build: () {
        when(() => deleteUseCase(projectId: projectId))
            .thenAnswer((_) async => const Left(NotFoundFailure()));
        return buildBloc();
      },
      seed: () => ProjectDetailsSuccess(
        project: project,
        tasks: tasks,
        taskSummary: populatedSummary,
      ),
      act: (bloc) => bloc.add(const DeleteProjectDetails(projectId)),
      expect: () => [
        const ProjectDetailsDeleteInProgress(),
        const ProjectDetailsDeleteFailure('The requested resource was not found.'),
      ],
    );
  });
}
