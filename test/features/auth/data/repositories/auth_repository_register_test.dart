import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:taskflow/core/error/exceptions.dart';
import 'package:taskflow/core/error/failures.dart';
import 'package:taskflow/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:taskflow/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:taskflow/features/auth/domain/entities/register_request.dart';

class MockAuthLocalDataSource extends Mock implements AuthLocalDataSource {}

void main() {
  late MockAuthLocalDataSource dataSource;
  late AuthRepositoryImpl repository;

  setUpAll(() {
    registerFallbackValue(
      const RegisterRequest(fullName: 'Fallback', email: 'fallback@test.dev', password: 'Fallback1!'),
    );
  });

  setUp(() {
    dataSource = MockAuthLocalDataSource();
    repository = AuthRepositoryImpl(dataSource);
  });

  group('AuthRepositoryImpl.register', () {
    const request = RegisterRequest(
      fullName: 'Jordan Blake',
      email: 'jordan.blake@nimbusdigital.test',
      password: 'Passw0rd!',
    );

    test('returns Success when the datasource registers without error', () async {
      when(() => dataSource.register(any())).thenAnswer((_) async {});

      final result = await repository.register(request);

      expect(result.isSuccess, isTrue);
      verify(() => dataSource.register(request)).called(1);
    });

    test('returns ResultFailure with ValidationFailure for a duplicate email', () async {
      when(() => dataSource.register(any())).thenThrow(const ValidationException('Email already registered'));

      final result = await repository.register(request);

      expect(result.isFailure, isTrue);
      expect(result.failureOrNull, isA<ValidationFailure>());
      expect(result.failureOrNull?.message, 'Email already registered');
    });
  });
}