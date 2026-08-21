import 'package:taskflow/core/error/result.dart';

abstract interface class AuthRepository {
  Future<Result<bool>> checkAuthenticationStatus();
}