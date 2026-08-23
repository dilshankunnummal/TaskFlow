import 'package:dartz/dartz.dart' hide Task;
import 'package:injectable/injectable.dart';
import 'package:taskflow/core/error/failures.dart';
import 'package:taskflow/features/tasks/domain/entities/task.dart';
import 'package:taskflow/features/tasks/domain/repositories/task_repository.dart';

@injectable
class GetProjectTasksUseCase {
  final TaskRepository repository;

  GetProjectTasksUseCase(this.repository);

  Future<Either<Failure, List<Task>>> call({required String projectId}) {
    return repository.getTasksByProject(projectId: projectId);
  }
}