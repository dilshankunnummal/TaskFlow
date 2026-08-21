import 'package:taskflow/core/error/result.dart';
import 'package:taskflow/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:taskflow/features/auth/domain/repositories/auth_repository.dart';

final class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._localDataSource);

  final AuthLocalDataSource _localDataSource;

  @override
  Future<Result<bool>> checkAuthenticationStatus() {
    return Result.guard(() => _localDataSource.hasValidSession());
  }
}