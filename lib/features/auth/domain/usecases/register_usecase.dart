import 'package:taskflow/core/error/result.dart';
import 'package:taskflow/features/auth/domain/entities/register_request.dart';
import 'package:taskflow/features/auth/domain/repositories/auth_repository.dart';

class RegisterUseCase {
  const RegisterUseCase(this._repository);

  final AuthRepository _repository;

  Future<Result<void>> call(RegisterRequest request) {
    return _repository.register(request);
  }
}