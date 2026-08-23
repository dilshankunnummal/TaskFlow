import 'package:taskflow/core/error/result.dart';
import 'package:taskflow/features/auth/domain/entities/session_status.dart';
import 'package:taskflow/features/auth/domain/repositories/auth_repository.dart';

class CheckSessionUseCase {
  const CheckSessionUseCase(this._repository);

  final AuthRepository _repository;

  Future<Result<SessionStatus>> call() {
    return _repository.getSessionStatus();
  }
}