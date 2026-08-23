import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:taskflow/core/error/failures.dart';
import 'package:taskflow/features/tasks/domain/repositories/task_repository.dart';

@injectable
class DeleteTaskUseCase {
  final TaskRepository _repository;

  DeleteTaskUseCase(this._repository);

  Future<Either<Failure, Unit>> call(String taskId) async {
    if (taskId.trim().isEmpty) {
      return const Left(ValidationFailure('taskId must not be empty'));
    }
    return _repository.deleteTask(taskId);
  }
}
