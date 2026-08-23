import 'package:dartz/dartz.dart' hide Task;
import 'package:injectable/injectable.dart';
import 'package:taskflow/core/error/failures.dart';
import 'package:taskflow/features/tasks/domain/entities/task.dart';
import 'package:taskflow/features/tasks/domain/repositories/task_repository.dart';

@injectable
class UnassignTaskUseCase {
  final TaskRepository _repository;

  UnassignTaskUseCase(this._repository);

  Future<Either<Failure, Task>> call(String taskId) async {
    if (taskId.trim().isEmpty) {
      return const Left(ValidationFailure('taskId must not be empty'));
    }
    return _repository.unassignTask(taskId);
  }
}
