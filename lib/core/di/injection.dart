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

final GetIt getIt = GetIt.instance;

Future<void> configureDependencies({Environment? environment}) async {
  AppEnvironment.current = environment ?? Environment.mock();

  if (!getIt.isRegistered<Connectivity>()) {
    getIt.registerLazySingleton<Connectivity>(Connectivity.new);
  }

  if (!getIt.isRegistered<NetworkInfo>()) {
    getIt.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(getIt<Connectivity>()));
  }

  if (!getIt.isRegistered<ConnectivityCubit>()) {
    getIt.registerLazySingleton<ConnectivityCubit>(() => ConnectivityCubit(getIt<NetworkInfo>()));
  }

  if (!getIt.isRegistered<FlutterSecureStorage>()) {
    getIt.registerLazySingleton<FlutterSecureStorage>(() => const FlutterSecureStorage());
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
    getIt.registerLazySingleton<MockJsonLoader>(() => MockJsonLoader(AppEnvironment.current));
  }
}

Future<void> resetDependencies() async {
  await getIt.reset();
}
