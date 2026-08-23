import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taskflow/core/config/environment.dart';
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
import 'package:taskflow/features/projects/data/repositories/projects_repository_impl.dart';
import 'package:taskflow/features/projects/domain/repositories/projects_repository.dart';
import 'package:taskflow/features/projects/domain/usecases/get_projects.dart';
import 'package:taskflow/features/projects/presentation/bloc/projects_bloc.dart';

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

  if (!getIt.isRegistered<ProjectsRepository>()) {
    getIt.registerLazySingleton<ProjectsRepository>(
      () => ProjectsRepositoryImpl(getIt<ProjectsDataSource>()),
    );
  }

  if (!getIt.isRegistered<GetProjects>()) {
    getIt.registerLazySingleton<GetProjects>(
        () => GetProjects(getIt<ProjectsRepository>()));
  }

  if (!getIt.isRegistered<ProjectsBloc>()) {
    getIt.registerFactory<ProjectsBloc>(
      () => ProjectsBloc(getIt<GetProjects>(), getIt<CurrentSession>()),
    );
  }
}

Future<void> resetDependencies() async {
  await getIt.reset();
}
