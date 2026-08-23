import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:taskflow/core/error/failures.dart';
import 'package:taskflow/core/network/connectivity_manager.dart';
import 'package:taskflow/features/profile/domain/entities/user_profile.dart';
import 'package:taskflow/features/profile/domain/repositories/profile_repository.dart';
import 'package:taskflow/features/profile/domain/usecases/get_current_user_usecase.dart';
import 'package:taskflow/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:taskflow/features/profile/presentation/bloc/profile_event.dart';
import 'package:taskflow/features/profile/presentation/bloc/profile_state.dart';

class MockGetCurrentUserUseCase extends Mock implements GetCurrentUserUseCase {}

class MockProfileRepository extends Mock implements ProfileRepository {}

class MockConnectivityManager extends Mock implements ConnectivityManager {}

void main() {
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
  });

  ProfileBloc buildBloc() => ProfileBloc(
        getCurrentUser,
        profileRepository,
        connectivityManager,
      );

  group('ProfileBloc', () {
    test('initial state is ProfileInitial', () {
      expect(buildBloc().state, const ProfileInitial());
    });

    blocTest<ProfileBloc, ProfileState>(
      'emits [ProfileLoading, ProfileSuccess] when LoadProfile succeeds',
      build: () {
        when(() => getCurrentUser())
            .thenAnswer((_) async => const Right(profile));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const LoadProfile()),
      expect: () => [
        const ProfileLoading(),
        const ProfileSuccess(profile: profile, isOffline: false),
      ],
    );

    blocTest<ProfileBloc, ProfileState>(
      'emits [ProfileLoading, ProfileError] when LoadProfile fails',
      build: () {
        when(() => getCurrentUser())
            .thenAnswer((_) async => const Left(UnknownFailure()));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const LoadProfile()),
      expect: () => [
        const ProfileLoading(),
        const ProfileError('An unexpected error occurred.'),
      ],
    );
  });
}
