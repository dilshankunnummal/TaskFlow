import 'package:dartz/dartz.dart' hide Task;
import 'package:taskflow/core/error/failures.dart';
import 'package:taskflow/features/tasks/domain/entities/task.dart';
import 'package:taskflow/features/tasks/domain/entities/task_details.dart';
import 'package:taskflow/features/tasks/domain/entities/task_assignee.dart';

abstract class TaskRepository {
  Future<Either<Failure, List<Task>>> getTasksByProject({required String projectId});

  Future<Either<Failure, List<Task>>> refreshTasks({required String projectId});

  Future<Either<Failure, TaskDetails>> getTaskDetails({required String taskId});

  Future<Either<Failure, Task>> createTask(Task task);

  Future<Either<Failure, List<TaskAssignee>>> getAssignees();
}