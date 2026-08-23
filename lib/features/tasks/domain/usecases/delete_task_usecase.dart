import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:taskflow/core/auth/current_session.dart';
import 'package:taskflow/core/error/failures.dart';
import 'package:taskflow/features/tasks/domain/repositories/task_repository.dart';

@injectable
class DeleteTaskUseCase {
  final TaskRepository _repository;
  final CurrentSession _session;

  DeleteTaskUseCase(this._repository, this._session);

  Future<Either<Failure, Unit>> call(String taskId) async {
    if (taskId.trim().isEmpty) {
      return const Left(ValidationFailure('taskId must not be empty'));
    }

    final role = await _session.currentUserRole;
    if (role != 'org_admin') {
      return const Left(
          UnauthorizedFailure('Only organization admins can delete tasks.'));
    }

    return _repository.deleteTask(taskId);
  }
}
