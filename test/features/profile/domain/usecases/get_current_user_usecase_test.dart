import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:taskflow/core/error/failures.dart';
import 'package:taskflow/features/profile/domain/entities/user_profile.dart';
import 'package:taskflow/features/profile/domain/repositories/profile_repository.dart';
import 'package:taskflow/features/profile/domain/usecases/get_current_user_usecase.dart';

class MockProfileRepository extends Mock implements ProfileRepository {}

void main() {
  late MockProfileRepository repository;
  late GetCurrentUserUseCase useCase;

  const profile = UserProfile(
    id: 'user_001',
    name: 'Ava Thompson',
    email: 'ava@test.com',
    avatarUrl: null,
    organizationName: 'Nimbus Digital',
    role: 'org_admin',
  );

  setUp(() {
    repository = MockProfileRepository();
    useCase = GetCurrentUserUseCase(repository);
  });

  group('GetCurrentUserUseCase', () {
    test('calls repository.getCurrentUserProfile and returns UserProfile',
        () async {
      when(() => repository.getCurrentUserProfile())
          .thenAnswer((_) async => const Right(profile));

      final result = await useCase();

      expect(result, const Right(profile));
      verify(() => repository.getCurrentUserProfile()).called(1);
    });

    test('returns Left(Failure) when repository throws error', () async {
      when(() => repository.getCurrentUserProfile())
          .thenAnswer((_) async => const Left(UnknownFailure()));

      final result = await useCase();

      expect(result, const Left(UnknownFailure()));
    });
  });
}
