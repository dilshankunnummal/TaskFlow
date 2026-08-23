import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taskflow/core/config/environment.dart';
import 'package:taskflow/core/constants/storage_keys.dart';
import 'package:taskflow/core/data/mock_json_loader.dart';
import 'package:taskflow/core/network/cubit/connectivity_cubit.dart';
import 'package:taskflow/core/network/network_info.dart';
import 'package:taskflow/core/network/simulated_network.dart';
import 'package:taskflow/core/utils/id_generator.dart';
import 'package:taskflow/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:taskflow/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:taskflow/features/auth/data/services/token_refresh_service.dart';
import 'package:taskflow/features/auth/data/services/token_refresh_service_impl.dart';
import 'package:taskflow/features/auth/domain/repositories/auth_repository.dart';
import 'package:taskflow/features/auth/domain/usecases/check_session_usecase.dart';
import 'package:taskflow/features/auth/domain/usecases/login_usecase.dart';
import 'package:taskflow/features/auth/domain/usecases/refresh_token_usecase.dart';
import 'package:taskflow/features/auth/domain/usecases/register_usecase.dart';
import 'package:taskflow/features/auth/presentation/bloc/login_bloc.dart';
import 'package:taskflow/features/auth/presentation/bloc/register_bloc.dart';
import 'package:taskflow/features/auth/presentation/bloc/splash_bloc.dart';
import 'package:taskflow/features/home/data/datasources/home_mock_datasource.dart';
import 'package:taskflow/features/home/data/repositories/home_repository_impl.dart';
import 'package:taskflow/features/home/domain/repositories/home_repository.dart';
import 'package:taskflow/features/home/domain/usecases/get_dashboard_data_usecase.dart';
import 'package:taskflow/features/home/presentation/bloc/dashboard_bloc.dart';
import 'package:taskflow/core/auth/current_session.dart';
import 'package:taskflow/core/data/mock_json_data_source.dart';
import 'package:taskflow/core/network/mock_network.dart';
import 'package:taskflow/features/projects/data/datasources/projects_datasource.dart';
import 'package:taskflow/features/projects/data/datasources/projects_local_datasource.dart';
import 'package:taskflow/features/projects/data/repositories/projects_repository_impl.dart';
import 'package:taskflow/features/projects/domain/repositories/projects_repository.dart';
import 'package:taskflow/features/projects/domain/usecases/get_projects.dart';
import 'package:taskflow/features/projects/domain/usecases/get_project_details_usecase.dart';
import 'package:taskflow/features/projects/domain/usecases/create_project_usecase.dart';
import 'package:taskflow/features/projects/domain/usecases/update_project_usecase.dart';
import 'package:taskflow/features/projects/domain/usecases/delete_project_usecase.dart';
import 'package:taskflow/features/projects/presentation/bloc/projects_bloc.dart';
import 'package:taskflow/features/projects/presentation/bloc/project_details_bloc.dart';
import 'package:taskflow/features/projects/presentation/bloc/project_form/project_form_bloc.dart';
import 'package:taskflow/features/tasks/data/datasources/tasks_datasource.dart';
import 'package:taskflow/features/tasks/data/datasources/tasks_local_datasource.dart';
import 'package:taskflow/features/tasks/data/repositories/task_repository_impl.dart';
import 'package:taskflow/features/tasks/domain/repositories/task_repository.dart';
import 'package:taskflow/features/tasks/domain/usecases/get_project_tasks_usecase.dart';
import 'package:taskflow/features/tasks/domain/usecases/get_task_details_usecase.dart';
import 'package:taskflow/features/tasks/domain/usecases/create_task_usecase.dart';
import 'package:taskflow/features/tasks/domain/usecases/get_assignees_usecase.dart';
import 'package:taskflow/features/tasks/presentation/bloc/task_details_bloc.dart';
import 'package:taskflow/features/tasks/presentation/bloc/task_list_bloc.dart';
import 'package:taskflow/features/tasks/presentation/bloc/task_create_bloc.dart';

final GetIt getIt = GetIt.instance;

Future<void> configureDependencies({Environment? environment}) async {
  AppEnvironment.current = environment ?? Environment.mock();

  if (!getIt.isRegistered<Connectivity>()) {
    getIt.registerLazySingleton<Connectivity>(Connectivity.new);
  }

  if (!getIt.isRegistered<NetworkInfo>()) {
    getIt.registerLazySingleton<NetworkInfo>(
            () => NetworkInfoImpl(getIt<Connectivity>()));
  }

  if (!getIt.isRegistered<ConnectivityCubit>()) {
    getIt.registerLazySingleton<ConnectivityCubit>(
            () => ConnectivityCubit(getIt<NetworkInfo>()));
  }

  if (!getIt.isRegistered<FlutterSecureStorage>()) {
    getIt.registerLazySingleton<FlutterSecureStorage>(
            () => const FlutterSecureStorage());
  }

  if (!getIt.isRegistered<SharedPreferences>()) {
    final preferences = await SharedPreferences.getInstance();
    getIt.registerSingleton<SharedPreferences>(preferences);
  }

  getIt.registerLazySingleton<IdGenerator>(
        () => const UuidIdGenerator(),
  );

  if (!getIt.isRegistered<SimulatedNetworkConfig>()) {
    getIt.registerLazySingleton<SimulatedNetworkConfig>(
          () => const SimulatedNetworkConfig(
        minDelayMs: 300,
        maxDelayMs: 800,
        forceNotFoundId: 'force-404',
        forceTimeoutId: 'force-timeout',
        forceValidationErrorId: 'force-validation',
      ),
    );
  }

  if (!getIt.isRegistered<SimulatedNetwork>()) {
    getIt.registerLazySingleton<SimulatedNetwork>(
          () => SimulatedNetwork(getIt<SimulatedNetworkConfig>()),
    );
  }

  if (!getIt.isRegistered<MockJsonLoader>()) {
    getIt.registerLazySingleton<MockJsonLoader>(
            () => MockJsonLoader(AppEnvironment.current));
  }

  if (!getIt.isRegistered<AuthLocalDataSource>()) {
    getIt.registerLazySingleton<AuthLocalDataSource>(
          () => AuthLocalDataSourceImpl(
        getIt<FlutterSecureStorage>(),
        getIt<MockJsonLoader>(),
        getIt<SimulatedNetwork>(),
        getIt<IdGenerator>(),
        getIt<TokenRefreshService>(),
      ),
    );
  }

  if (!getIt.isRegistered<AuthRepository>()) {
    getIt.registerLazySingleton<AuthRepository>(
          () => AuthRepositoryImpl(getIt<AuthLocalDataSource>()),
    );
  }

  if (!getIt.isRegistered<TokenRefreshService>()) {
    getIt.registerLazySingleton<TokenRefreshService>(
          () => TokenRefreshServiceImpl(
        getIt<SimulatedNetwork>(),
        getIt<MockJsonLoader>(),
        getIt<IdGenerator>(),
      ),
    );
  }

  if (!getIt.isRegistered<LoginUseCase>()) {
    getIt.registerLazySingleton<LoginUseCase>(
            () => LoginUseCase(getIt<AuthRepository>()));
  }

  if (!getIt.isRegistered<LoginBloc>()) {
    getIt.registerFactory<LoginBloc>(() => LoginBloc(getIt<LoginUseCase>()));
  }

  if (!getIt.isRegistered<RegisterUseCase>()) {
    getIt.registerLazySingleton<RegisterUseCase>(
            () => RegisterUseCase(getIt<AuthRepository>()));
  }

  if (!getIt.isRegistered<RegisterBloc>()) {
    getIt.registerFactory<RegisterBloc>(
            () => RegisterBloc(getIt<RegisterUseCase>()));
  }

  if (!getIt.isRegistered<CheckSessionUseCase>()) {
    getIt.registerLazySingleton<CheckSessionUseCase>(
            () => CheckSessionUseCase(getIt<AuthRepository>()));
  }

  if (!getIt.isRegistered<RefreshTokenUseCase>()) {
    getIt.registerLazySingleton<RefreshTokenUseCase>(
            () => RefreshTokenUseCase(getIt<AuthRepository>()));
  }

  if (!getIt.isRegistered<SplashBloc>()) {
    getIt.registerFactory<SplashBloc>(
          () => SplashBloc(
          getIt<CheckSessionUseCase>(), getIt<RefreshTokenUseCase>()),
    );
  }

  if (!getIt.isRegistered<HomeMockDataSource>()) {
    getIt.registerLazySingleton<HomeMockDataSource>(
          () => HomeMockDataSourceImpl(
          getIt<MockJsonLoader>(), getIt<SimulatedNetwork>()),
    );
  }

  if (!getIt.isRegistered<HomeRepository>()) {
    getIt.registerLazySingleton<HomeRepository>(
          () => HomeRepositoryImpl(
          getIt<AuthRepository>(), getIt<HomeMockDataSource>()),
    );
  }

  if (!getIt.isRegistered<GetDashboardDataUseCase>()) {
    getIt.registerLazySingleton<GetDashboardDataUseCase>(
          () => GetDashboardDataUseCase(getIt<HomeRepository>()),
    );
  }

  if (!getIt.isRegistered<DashboardBloc>()) {
    getIt.registerFactory<DashboardBloc>(
          () => DashboardBloc(getIt<GetDashboardDataUseCase>()),
    );
  }

  if (!getIt.isRegistered<MockJsonDataSource>()) {
    getIt.registerLazySingleton<MockJsonDataSource>(() => MockJsonDataSource());
  }

  if (!getIt.isRegistered<MockNetwork>()) {
    getIt.registerLazySingleton<MockNetwork>(() => MockNetwork.instance);
  }

  if (!getIt.isRegistered<CurrentSession>()) {
    getIt.registerLazySingleton<CurrentSession>(
          () => CurrentSessionImpl(getIt<FlutterSecureStorage>()),
    );
  }
  if (!getIt.isRegistered<ProjectsDataSource>()) {
    getIt.registerLazySingleton<ProjectsDataSource>(
          () => MockProjectsDataSource(
          getIt<MockJsonDataSource>(), getIt<MockNetwork>()),
    );
  }

  if (!getIt.isRegistered<Box>(instanceName: HiveBoxNames.projectsCache)) {
    final projectsBox = await Hive.openBox(HiveBoxNames.projectsCache);
    getIt.registerLazySingleton<Box>(
          () => projectsBox,
      instanceName: HiveBoxNames.projectsCache,
    );
  }

  if (!getIt.isRegistered<ProjectsLocalDataSource>()) {
    getIt.registerLazySingleton<ProjectsLocalDataSource>(
          () => HiveProjectsLocalDataSource(
        getIt<Box>(instanceName: HiveBoxNames.projectsCache),
        getIt<MockNetwork>(),
      ),
    );
  }

  if (!getIt.isRegistered<ProjectsRepository>()) {
    getIt.registerLazySingleton<ProjectsRepository>(
          () => ProjectsRepositoryImpl(
        getIt<ProjectsDataSource>(),
        getIt<ProjectsLocalDataSource>(),
      ),
    );
  }

  if (!getIt.isRegistered<GetProjects>()) {
    getIt.registerLazySingleton<GetProjects>(
            () => GetProjects(getIt<ProjectsRepository>()));
  }

  if (!getIt.isRegistered<GetProjectDetailsUseCase>()) {
    getIt.registerLazySingleton<GetProjectDetailsUseCase>(
            () => GetProjectDetailsUseCase(getIt<ProjectsRepository>()));
  }

  if (!getIt.isRegistered<CreateProjectUseCase>()) {
    getIt.registerLazySingleton<CreateProjectUseCase>(
          () => CreateProjectUseCase(
          getIt<ProjectsRepository>(), getIt<IdGenerator>()),
    );
  }

  if (!getIt.isRegistered<UpdateProjectUseCase>()) {
    getIt.registerLazySingleton<UpdateProjectUseCase>(
            () => UpdateProjectUseCase(getIt<ProjectsRepository>()));
  }

  if (!getIt.isRegistered<DeleteProjectUseCase>()) {
    getIt.registerLazySingleton<DeleteProjectUseCase>(
          () => DeleteProjectUseCase(
          getIt<ProjectsRepository>(), getIt<CurrentSession>()),
    );
  }

  if (!getIt.isRegistered<ProjectsBloc>()) {
    getIt.registerFactory<ProjectsBloc>(
          () => ProjectsBloc(
        getIt<GetProjects>(),
        getIt<DeleteProjectUseCase>(),
        getIt<CurrentSession>(),
      ),
    );
  }

  if (!getIt.isRegistered<ProjectDetailsBloc>()) {
    getIt.registerFactory<ProjectDetailsBloc>(
          () => ProjectDetailsBloc(
        getIt<GetProjectDetailsUseCase>(),
        getIt<DeleteProjectUseCase>(),
      ),
    );
  }

  if (!getIt.isRegistered<ProjectFormBloc>()) {
    getIt.registerFactory<ProjectFormBloc>(
          () => ProjectFormBloc(
        getIt<CreateProjectUseCase>(),
        getIt<UpdateProjectUseCase>(),
        getIt<DeleteProjectUseCase>(),
        getIt<CurrentSession>(),
      ),
    );
  }

  if (!getIt.isRegistered<TasksDataSource>()) {
    getIt.registerLazySingleton<TasksDataSource>(
          () => MockTasksDataSource(
          getIt<MockJsonDataSource>(), getIt<MockNetwork>()),
    );
  }

  if (!getIt.isRegistered<Box>(instanceName: HiveBoxNames.tasksCache)) {
    final tasksBox = await Hive.openBox(HiveBoxNames.tasksCache);
    getIt.registerLazySingleton<Box>(
          () => tasksBox,
      instanceName: HiveBoxNames.tasksCache,
    );
  }

  if (!getIt.isRegistered<TasksLocalDataSource>()) {
    getIt.registerLazySingleton<TasksLocalDataSource>(
          () => HiveTasksLocalDataSource(
        getIt<Box>(instanceName: HiveBoxNames.tasksCache),
      ),
    );
  }

  if (!getIt.isRegistered<TaskRepository>()) {
    getIt.registerLazySingleton<TaskRepository>(
          () => TaskRepositoryImpl(
        getIt<TasksDataSource>(),
        getIt<TasksLocalDataSource>(),
      ),
    );
  }

  if (!getIt.isRegistered<GetProjectTasksUseCase>()) {
    getIt.registerLazySingleton<GetProjectTasksUseCase>(
          () => GetProjectTasksUseCase(getIt<TaskRepository>()),
    );
  }

  if (!getIt.isRegistered<GetTaskDetailsUseCase>()) {
    getIt.registerLazySingleton<GetTaskDetailsUseCase>(
          () => GetTaskDetailsUseCase(getIt<TaskRepository>()),
    );
  }

  if (!getIt.isRegistered<TaskListBloc>()) {
    getIt.registerFactory<TaskListBloc>(
          () => TaskListBloc(
        getIt<GetProjectTasksUseCase>(),
        getIt<TaskRepository>(),
      ),
    );
  }

  if (!getIt.isRegistered<TaskDetailsBloc>()) {
    getIt.registerFactory<TaskDetailsBloc>(
          () => TaskDetailsBloc(getIt<GetTaskDetailsUseCase>()),
    );
  }

  if (!getIt.isRegistered<CreateTaskUseCase>()) {
    getIt.registerLazySingleton<CreateTaskUseCase>(
          () => CreateTaskUseCase(getIt<TaskRepository>(), getIt<IdGenerator>()),
    );
  }

  if (!getIt.isRegistered<GetAssigneesUseCase>()) {
    getIt.registerLazySingleton<GetAssigneesUseCase>(
          () => GetAssigneesUseCase(getIt<TaskRepository>()),
    );
  }

  if (!getIt.isRegistered<TaskCreateBloc>()) {
    getIt.registerFactory<TaskCreateBloc>(
          () => TaskCreateBloc(getIt<CreateTaskUseCase>(), getIt<GetAssigneesUseCase>()),
    );
  }
}

Future<void> resetDependencies() async {
  await getIt.reset();
}