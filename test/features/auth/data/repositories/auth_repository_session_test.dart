import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:taskflow/core/error/exceptions.dart';
import 'package:taskflow/core/error/failures.dart';
import 'package:taskflow/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:taskflow/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:taskflow/features/auth/domain/entities/session_status.dart';

class MockAuthLocalDataSource extends Mock implements AuthLocalDataSource {}

void main() {
  late MockAuthLocalDataSource dataSource;
  late AuthRepositoryImpl repository;

  setUp(() {
    dataSource = MockAuthLocalDataSource();
    repository = AuthRepositoryImpl(dataSource);
  });

  group('AuthRepositoryImpl.getSessionStatus', () {
    test('returns Success(valid) when a stored token exists and has not expired', () async {
      when(() => dataSource.getSessionStatus()).thenAnswer((_) async => SessionStatus.valid);

      final result = await repository.getSessionStatus();

      expect(result.isSuccess, isTrue);
      expect(result.valueOrNull, SessionStatus.valid);
    });

    test('returns Success(none) when there is no stored token', () async {
      when(() => dataSource.getSessionStatus()).thenAnswer((_) async => SessionStatus.none);

      final result = await repository.getSessionStatus();

      expect(result.isSuccess, isTrue);
      expect(result.valueOrNull, SessionStatus.none);
    });
  });

  group('AuthRepositoryImpl.refreshSession', () {
    test('returns Success when the datasource refreshes without error', () async {
      when(() => dataSource.refreshSession()).thenAnswer((_) async {});

      final result = await repository.refreshSession();

      expect(result.isSuccess, isTrue);
    });

    test('returns ResultFailure when the refresh token is invalid', () async {
      when(() => dataSource.refreshSession())
          .thenThrow(const AuthException('The refresh token is invalid or has expired.'));

      final result = await repository.refreshSession();

      expect(result.isFailure, isTrue);
      expect(result.failureOrNull, isA<AuthFailure>());
    });
  });
}