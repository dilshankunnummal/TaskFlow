import 'package:dartz/dartz.dart' hide Task;
import 'package:injectable/injectable.dart';
import 'package:taskflow/core/error/failures.dart';
import 'package:taskflow/features/tasks/domain/entities/task.dart';
import 'package:taskflow/features/tasks/domain/repositories/task_repository.dart';

@injectable
class AssignTaskUseCase {
  final TaskRepository _repository;

  AssignTaskUseCase(this._repository);

  Future<Either<Failure, Task>> call({
    required String taskId,
    required String userId,
  }) async {
    if (taskId.trim().isEmpty) {
      return const Left(ValidationFailure('taskId must not be empty'));
    }
    if (userId.trim().isEmpty) {
      return const Left(ValidationFailure('userId must not be empty'));
    }
    return _repository.assignTask(taskId: taskId, userId: userId);
  }
}
