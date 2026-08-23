import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:taskflow/core/error/failures.dart';
import 'package:taskflow/core/network/connectivity_manager.dart';
import 'package:taskflow/core/theme/app_theme.dart';
import 'package:taskflow/features/profile/domain/entities/user_profile.dart';
import 'package:taskflow/features/profile/domain/repositories/profile_repository.dart';
import 'package:taskflow/features/profile/domain/usecases/get_current_user_usecase.dart';
import 'package:taskflow/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:taskflow/features/profile/presentation/pages/profile_settings_page.dart';

class MockGetCurrentUserUseCase extends Mock implements GetCurrentUserUseCase {}

class MockProfileRepository extends Mock implements ProfileRepository {}

class MockConnectivityManager extends Mock implements ConnectivityManager {}

void main() {
  final getIt = GetIt.instance;
  late MockGetCurrentUserUseCase getCurrentUser;
  late MockProfileRepository profileRepository;
  late MockConnectivityManager connectivityManager;

  const profile = UserProfile(
    id: 'user_001',
    name: 'Ava Thompson',
    email: 'ava@test.com',
    avatarUrl: null,
    organizationName: 'Nimbus Digital',
    role: 'org_admin',
  );

  setUp(() {
    getCurrentUser = MockGetCurrentUserUseCase();
    profileRepository = MockProfileRepository();
    connectivityManager = MockConnectivityManager();

    when(() => connectivityManager.isOnline).thenReturn(true);
    when(() => connectivityManager.onConnectivityChanged)
        .thenAnswer((_) => const Stream.empty());

    getIt
      ..reset()
      ..registerFactory<GetCurrentUserUseCase>(() => getCurrentUser)
      ..registerFactory<ProfileRepository>(() => profileRepository)
      ..registerFactory<ConnectivityManager>(() => connectivityManager)
      ..registerFactory<ProfileBloc>(
        () => ProfileBloc(
          getCurrentUser,
          profileRepository,
          connectivityManager,
        ),
      );
  });

  tearDown(() async {
    await getIt.reset();
  });

  Widget buildPage() {
    return MaterialApp(
      theme: AppTheme.dark(),
      home: const ProfileSettingsPage(),
    );
  }

  testWidgets('renders user profile details on success', (tester) async {
    when(() => getCurrentUser())
        .thenAnswer((_) async => const Right(profile));

    await tester.pumpWidget(buildPage());
    await tester.pumpAndSettle();

    expect(find.text('Ava Thompson'), findsOneWidget);
    expect(find.text('ava@test.com'), findsOneWidget);
    expect(find.text('Nimbus Digital'), findsOneWidget);
    expect(find.text('Org Admin'), findsWidgets);
  });

  testWidgets('shows offline banner when offline mode is active',
      (tester) async {
    when(() => connectivityManager.isOnline).thenReturn(false);
    when(() => getCurrentUser())
        .thenAnswer((_) async => const Right(profile));

    await tester.pumpWidget(buildPage());
    await tester.pumpAndSettle();

    expect(find.text("You're offline. Showing cached data."), findsOneWidget);
    expect(find.text('Last updated data may be outdated'), findsOneWidget);
  });

  testWidgets('shows error state widget on failure', (tester) async {
    when(() => getCurrentUser())
        .thenAnswer((_) async => const Left(UnknownFailure()));

    await tester.pumpWidget(buildPage());
    await tester.pumpAndSettle();

    expect(find.text('An unexpected error occurred.'), findsWidgets);
    expect(find.text('Retry'), findsOneWidget);
  });
}
