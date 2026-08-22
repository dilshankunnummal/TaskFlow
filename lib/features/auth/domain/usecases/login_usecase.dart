import 'package:taskflow/core/error/result.dart';
import 'package:taskflow/features/auth/domain/entities/user_entity.dart';
import 'package:taskflow/features/auth/domain/repositories/auth_repository.dart';

final class LoginUseCase {
  const LoginUseCase(this._repository);

  final AuthRepository _repository;

  Future<Result<UserEntity>> call({required String email, required String password}) {
    return _repository.login(email: email, password: password);
  }
}
