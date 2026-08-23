import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:taskflow/core/auth/current_session.dart';
import 'package:taskflow/core/error/failures.dart';
import 'package:taskflow/core/theme/app_theme.dart';
import 'package:taskflow/core/utils/id_generator.dart';
import 'package:taskflow/features/projects/data/repositories/projects_repository_impl.dart';
import 'package:taskflow/features/projects/domain/entities/project.dart';
import 'package:taskflow/features/projects/domain/entities/project_task.dart';
import 'package:taskflow/features/projects/domain/repositories/projects_repository.dart';
import 'package:taskflow/features/projects/domain/usecases/create_project_usecase.dart';
import 'package:taskflow/features/projects/domain/usecases/delete_project_usecase.dart';
import 'package:taskflow/features/projects/domain/usecases/get_project_details_usecase.dart';
import 'package:taskflow/features/projects/domain/usecases/get_projects.dart';
import 'package:taskflow/features/projects/domain/usecases/update_project_usecase.dart';
import 'package:taskflow/features/projects/presentation/bloc/project_details_bloc.dart';
import 'package:taskflow/features/projects/presentation/bloc/project_form/project_form_bloc.dart';
import 'package:taskflow/features/projects/presentation/bloc/projects_bloc.dart';
import 'package:taskflow/features/projects/presentation/pages/create_project_page.dart';
import 'package:taskflow/features/projects/presentation/pages/edit_project_page.dart';
import 'package:taskflow/features/projects/presentation/pages/project_details_page.dart';
import 'package:taskflow/features/projects/presentation/pages/projects_list_page.dart';

const _orgId = 'org_test_1';
const _seedProjectId = 'proj_seed_1';

class FakeInMemoryProjectsRepository implements ProjectsRepository {
  final Map<String, Project> _projectsById = {};

  void seed(Project project) {
    _projectsById[project.id] = project;
  }

  @override
  Future<Either<Failure, List<Project>>> getProjects({required String orgId}) async {
    return Right(_projectsById.values.where((project) => project.orgId == orgId).toList());
  }

  @override
  Future<Either<Failure, Project>> getProjectById({required String projectId}) async {
    final project = _projectsById[projectId];
    if (project == null) {
      return const Left(NotFoundFailure());
    }
    return Right(project);
  }

  @override
  Future<Either<Failure, List<ProjectTask>>> getProjectTasks({required String projectId}) async {
    return const Right([]);
  }

  @override
  Future<Either<Failure, Project>> createProject({required Project project}) async {
    _projectsById[project.id] = project;
    return Right(project);
  }

  @override
  Future<Either<Failure, Project>> updateProject({required Project project}) async {
    _projectsById[project.id] = project;
    return Right(project);
  }

  @override
  Future<Either<Failure, Unit>> deleteProject({required String projectId}) async {
    _projectsById.remove(projectId);
    return const Right(unit);
  }
}

class FakeCurrentSession implements CurrentSession {
  FakeCurrentSession({required String role}) : _role = role;

  final String _role;

  @override
  Future<String?> get currentOrgId async => _orgId;

  @override
  Future<String?> get currentUserId async => 'user_test_1';

  @override
  Future<String?> get currentUserRole async => _role;
}

class SequentialIdGenerator implements IdGenerator {
  int _counter = 0;

  @override
  String generate() {
    _counter += 1;
    return 'proj_generated_$_counter';
  }
}

void main() {
  late FakeInMemoryProjectsRepository repository;
  late GetIt getIt;

  Project buildSeedProject() {
    return Project(
      id: _seedProjectId,
      orgId: _orgId,
      name: 'Atlas Redesign',
      description: 'Refresh the marketing site.',
      status: ProjectStatus.active,
      taskCount: 0,
      createdAt: DateTime(2026, 1, 1),
    );
  }

  void registerDependencies({required String role}) {
    repository = FakeInMemoryProjectsRepository();
    repository.seed(buildSeedProject());

    final session = FakeCurrentSession(role: role);
    final idGenerator = SequentialIdGenerator();

    getIt = GetIt.instance;
    getIt.registerLazySingleton<ProjectsRepository>(() => repository);
    getIt.registerLazySingleton<CurrentSession>(() => session);
    getIt.registerLazySingleton<IdGenerator>(() => idGenerator);
    getIt.registerLazySingleton<GetProjects>(() => GetProjects(getIt<ProjectsRepository>()));
    getIt.registerLazySingleton<GetProjectDetailsUseCase>(
        () => GetProjectDetailsUseCase(getIt<ProjectsRepository>()));
    getIt.registerLazySingleton<CreateProjectUseCase>(
        () => CreateProjectUseCase(getIt<ProjectsRepository>(), getIt<IdGenerator>()));
    getIt.registerLazySingleton<UpdateProjectUseCase>(
        () => UpdateProjectUseCase(getIt<ProjectsRepository>()));
    getIt.registerLazySingleton<DeleteProjectUseCase>(
        () => DeleteProjectUseCase(getIt<ProjectsRepository>(), getIt<CurrentSession>()));
    getIt.registerFactory<ProjectsBloc>(() => ProjectsBloc(
          getIt<GetProjects>(),
          getIt<DeleteProjectUseCase>(),
          getIt<CurrentSession>(),
        ));
    getIt.registerFactory<ProjectDetailsBloc>(() => ProjectDetailsBloc(
          getIt<GetProjectDetailsUseCase>(),
          getIt<DeleteProjectUseCase>(),
        ));
    getIt.registerFactory<ProjectFormBloc>(() => ProjectFormBloc(
          getIt<CreateProjectUseCase>(),
          getIt<UpdateProjectUseCase>(),
          getIt<DeleteProjectUseCase>(),
          getIt<CurrentSession>(),
        ));
  }

  GoRouter buildRouter() {
    return GoRouter(
      initialLocation: '/projects',
      routes: [
        GoRoute(
          path: '/projects',
          builder: (context, state) => const ProjectsListPage(),
        ),
        GoRoute(
          path: '/projects/create',
          builder: (context, state) => const CreateProjectPage(),
        ),
        GoRoute(
          path: '/projects/:projectId/edit',
          builder: (context, state) => EditProjectPage(project: state.extra as Project),
        ),
        GoRoute(
          path: '/projects/:projectId',
          builder: (context, state) => ProjectDetailsPage(
            projectId: state.pathParameters['projectId']!,
          ),
        ),
      ],
    );
  }

  Future<void> pumpProjectsApp(WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp.router(theme: AppTheme.dark(), routerConfig: buildRouter()));
    await tester.pumpAndSettle();
  }

  setUp(() {
    registerDependencies(role: 'org_admin');
  });

  tearDown(() async {
    await getIt.reset();
  });

  group('Project CRUD integration', () {
    testWidgets('opening the projects list shows existing projects', (tester) async {
      await pumpProjectsApp(tester);

      expect(find.text('Projects'), findsOneWidget);
      expect(find.text('Atlas Redesign'), findsOneWidget);
    });

    testWidgets('creating a project refreshes the projects list', (tester) async {
      await pumpProjectsApp(tester);

      await tester.tap(find.byIcon(Icons.add_rounded));
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('projectNameField')), 'Nebula Launch');
      await tester.enterText(
        find.byKey(const Key('projectDescriptionField')),
        'Coordinate the Nebula product launch.',
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('submitProjectButton')));
      await tester.pumpAndSettle();

      expect(find.text('Projects'), findsOneWidget);
      expect(find.text('Nebula Launch'), findsOneWidget);
      expect(find.text('Atlas Redesign'), findsOneWidget);

      final projects = await repository.getProjects(orgId: _orgId);
      expect(projects.getOrElse(() => const []).length, 2);
    });

    testWidgets('editing a project updates the details and list', (tester) async {
      await pumpProjectsApp(tester);

      await tester.tap(find.text('Atlas Redesign'));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.edit_outlined));
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('projectNameField')), 'Atlas Redesign 2.0');
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('submitProjectButton')));
      await tester.pumpAndSettle();

      expect(find.text('Atlas Redesign 2.0'), findsOneWidget);

      await tester.pageBack();
      await tester.pumpAndSettle();

      expect(find.text('Atlas Redesign 2.0'), findsOneWidget);
      expect(find.text('Atlas Redesign'), findsNothing);
    });

    testWidgets('deleting a project from the details page removes it from the list', (tester) async {
      await pumpProjectsApp(tester);

      await tester.tap(find.text('Atlas Redesign'));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('deleteProjectAction')));
      await tester.pumpAndSettle();

      expect(find.text('Delete project'), findsOneWidget);

      await tester.tap(find.text('Delete').last);
      await tester.pumpAndSettle();

      expect(find.text('Projects'), findsOneWidget);
      expect(find.text('Atlas Redesign'), findsNothing);
      expect(find.text('No projects yet'), findsOneWidget);

      final projects = await repository.getProjects(orgId: _orgId);
      expect(projects.getOrElse(() => const []), isEmpty);
    });

    testWidgets('a member cannot delete a project even from the UI action', (tester) async {
      await getIt.reset();
      registerDependencies(role: 'member');

      await pumpProjectsApp(tester);

      await tester.tap(find.text('Atlas Redesign'));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('deleteProjectAction')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete').last);
      await tester.pumpAndSettle();

      expect(find.text('You do not have permission to perform this action.'), findsOneWidget);

      final projects = await repository.getProjects(orgId: _orgId);
      expect(projects.getOrElse(() => const []).length, 1);
    });
  });
}
