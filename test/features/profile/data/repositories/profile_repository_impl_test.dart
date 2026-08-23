import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:taskflow/core/error/failures.dart';
import 'package:taskflow/core/network/connectivity_manager.dart';
import 'package:taskflow/features/auth/domain/repositories/auth_repository.dart';
import 'package:taskflow/features/profile/data/datasources/profile_datasource.dart';
import 'package:taskflow/features/profile/data/models/user_profile_model.dart';
import 'package:taskflow/features/profile/data/repositories/profile_repository_impl.dart';

class MockProfileDataSource extends Mock implements ProfileDataSource {}

class MockAuthRepository extends Mock implements AuthRepository {}

class MockConnectivityManager extends Mock implements ConnectivityManager {}

void main() {
  late MockProfileDataSource dataSource;
  late MockAuthRepository authRepository;
  late MockConnectivityManager connectivityManager;
  late ProfileRepositoryImpl repository;

  const profileModel = UserProfileModel(
    id: 'user_001',
    name: 'Ava Thompson',
    email: 'ava@test.com',
    avatarUrl: null,
    organizationName: 'Nimbus Digital',
    role: 'org_admin',
  );

  setUp(() {
    dataSource = MockProfileDataSource();
    authRepository = MockAuthRepository();
    connectivityManager = MockConnectivityManager();
    repository = ProfileRepositoryImpl(
      dataSource,
      authRepository,
      connectivityManager,
    );
  });

  group('ProfileRepositoryImpl.getCurrentUserProfile', () {
    test('fetches from datasource and caches profile when online', () async {
      when(() => connectivityManager.isOnline).thenReturn(true);
      when(() => dataSource.getCurrentUserProfile())
          .thenAnswer((_) async => profileModel);

      final result = await repository.getCurrentUserProfile();

      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('Expected Right'),
        (profile) => expect(profile.name, 'Ava Thompson'),
      );
    });

    test('returns cached profile when offline and cache exists', () async {
      when(() => connectivityManager.isOnline).thenReturn(true);
      when(() => dataSource.getCurrentUserProfile())
          .thenAnswer((_) async => profileModel);

      await repository.getCurrentUserProfile();

      when(() => connectivityManager.isOnline).thenReturn(false);

      final result = await repository.getCurrentUserProfile();

      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('Expected Right'),
        (profile) => expect(profile.name, 'Ava Thompson'),
      );
    });

    test('returns Left(OfflineFailure) when offline and no cache exists',
        () async {
      when(() => connectivityManager.isOnline).thenReturn(false);

      final result = await repository.getCurrentUserProfile();

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<OfflineFailure>()),
        (_) => fail('Expected Left'),
      );
    });
  });
}
