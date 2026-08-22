import 'package:taskflow/core/error/result.dart';
import 'package:taskflow/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:taskflow/features/auth/data/models/login_request.dart';
import 'package:taskflow/features/auth/data/models/session_model.dart';
import 'package:taskflow/features/auth/domain/entities/user_entity.dart';
import 'package:taskflow/features/auth/domain/repositories/auth_repository.dart';

final class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._localDataSource);

  final AuthLocalDataSource _localDataSource;

  @override
  Future<Result<bool>> checkAuthenticationStatus() {
    return Result.guard(() => _localDataSource.hasValidSession());
  }

  @override
  Future<Result<bool>> isLoggedIn() {
    return checkAuthenticationStatus();
  }

  @override
  Future<Result<UserEntity>> login({required String email, required String password}) {
    return Result.guard(() async {
      final response = await _localDataSource.login(LoginRequest(email: email, password: password));

      final loginTimestamp = DateTime.now();
      final session = SessionModel(
        accessToken: response.accessToken,
        refreshToken: response.refreshToken,
        accessTokenExpiresAt: loginTimestamp.add(Duration(seconds: response.expiresInSeconds)),
        userId: response.user.id,
        orgId: response.user.orgId,
        role: response.user.role,
        loginTimestamp: loginTimestamp,
      );

      await _localDataSource.persistSession(session);

      return response.user.toEntity();
    });
  }

  @override
  Future<Result<void>> logout() {
    return Result.guard(() => _localDataSource.clearSession());
  }

  @override
  Future<Result<UserEntity?>> getCurrentUser() {
    return Result.guard(() async {
      final user = await _localDataSource.getCurrentUser();
      return user?.toEntity();
    });
  }
}
