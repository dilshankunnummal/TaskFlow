import 'package:dartz/dartz.dart' hide Task;
import 'package:injectable/injectable.dart';
import 'package:taskflow/core/error/failures.dart';
import 'package:taskflow/features/tasks/domain/entities/task_details.dart';
import 'package:taskflow/features/tasks/domain/repositories/task_repository.dart';

@injectable
class GetTaskDetailsUseCase {
  final TaskRepository repository;

  GetTaskDetailsUseCase(this.repository);

  Future<Either<Failure, TaskDetails>> call({required String taskId}) {
    return repository.getTaskDetails(taskId: taskId);
  }
}
