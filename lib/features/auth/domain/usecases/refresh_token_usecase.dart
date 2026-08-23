import 'package:taskflow/core/error/result.dart';
import 'package:taskflow/features/auth/domain/repositories/auth_repository.dart';

class RefreshTokenUseCase {
  const RefreshTokenUseCase(this._repository);

  final AuthRepository _repository;

  Future<Result<void>> call() {
    return _repository.refreshSession();
  }
}