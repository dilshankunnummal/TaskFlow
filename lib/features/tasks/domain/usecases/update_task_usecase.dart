import 'package:dartz/dartz.dart' hide Task;
import 'package:injectable/injectable.dart';
import 'package:taskflow/core/error/failures.dart';
import 'package:taskflow/features/tasks/domain/entities/task.dart';
import 'package:taskflow/features/tasks/domain/repositories/task_repository.dart';

@injectable
class UpdateTaskUseCase {
  final TaskRepository _repository;

  UpdateTaskUseCase(this._repository);

  Future<Either<Failure, Task>> call({
    required String id,
    required String projectId,
    required String title,
    required String description,
    required TaskStatus status,
    required TaskPriority priority,
    required String? assigneeId,
    required DateTime? dueDate,
    required DateTime createdAt,
  }) async {
    if (title.trim().isEmpty) {
      return const Left(ValidationFailure('Task title must not be empty'));
    }
    if (description.trim().isEmpty) {
      return const Left(ValidationFailure('Task description must not be empty'));
    }
    if (dueDate != null) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final compareDate = DateTime(dueDate.year, dueDate.month, dueDate.day);
      if (compareDate.isBefore(today)) {
        return const Left(ValidationFailure('Due date cannot be in the past'));
      }
    }

    final task = Task(
      id: id,
      projectId: projectId,
      title: title.trim(),
      description: description.trim(),
      status: status,
      priority: priority,
      assigneeId: assigneeId,
      dueDate: dueDate,
      createdAt: createdAt,
    );

    return _repository.updateTask(task);
  }
}
