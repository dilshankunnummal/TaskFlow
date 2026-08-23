import 'package:taskflow/core/error/result.dart';
import 'package:taskflow/features/auth/domain/entities/register_request.dart';
import 'package:taskflow/features/auth/domain/entities/session_status.dart';
import 'package:taskflow/features/auth/domain/entities/user_entity.dart';

abstract interface class AuthRepository {
  Future<Result<bool>> checkAuthenticationStatus();

  Future<Result<bool>> isLoggedIn();

  Future<Result<UserEntity>> login({required String email, required String password});

  Future<Result<void>> logout();

  Future<Result<UserEntity?>> getCurrentUser();

  Future<Result<void>> register(RegisterRequest request);

  Future<Result<SessionStatus>> getSessionStatus();

  Future<Result<void>> refreshSession();
}
