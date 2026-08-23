import 'package:dartz/dartz.dart' hide Task;
import 'package:injectable/injectable.dart';
import 'package:taskflow/core/error/failures.dart';
import 'package:taskflow/core/utils/id_generator.dart';
import 'package:taskflow/features/tasks/domain/entities/task.dart';
import 'package:taskflow/features/tasks/domain/repositories/task_repository.dart';

@injectable
class CreateTaskUseCase {
  final TaskRepository _repository;
  final IdGenerator _idGenerator;

  CreateTaskUseCase(this._repository, this._idGenerator);

  Future<Either<Failure, Task>> call({
    required String projectId,
    required String title,
    required String description,
    required TaskStatus status,
    required TaskPriority priority,
    required String? assigneeId,
    required DateTime? dueDate,
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
      id: _idGenerator.generate(),
      projectId: projectId,
      title: title.trim(),
      description: description.trim(),
      status: status,
      priority: priority,
      assigneeId: assigneeId,
      dueDate: dueDate,
      createdAt: DateTime.now(),
    );

    return _repository.createTask(task);
  }
}
