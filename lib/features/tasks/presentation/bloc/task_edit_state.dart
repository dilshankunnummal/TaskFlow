import 'package:equatable/equatable.dart';
import 'package:taskflow/features/tasks/domain/entities/task.dart';
import 'package:taskflow/features/tasks/domain/entities/task_assignee.dart';

sealed class TaskEditState extends Equatable {
  final Task? task;
  final List<TaskAssignee> assignees;

  const TaskEditState({
    this.task,
    this.assignees = const [],
  });

  @override
  List<Object?> get props => [task, assignees];
}

final class TaskEditInitial extends TaskEditState {
  const TaskEditInitial({super.task, super.assignees});
}

final class TaskEditLoading extends TaskEditState {
  const TaskEditLoading({super.task, super.assignees});
}

final class TaskEditLoaded extends TaskEditState {
  const TaskEditLoaded({
    required Task task,
    required List<TaskAssignee> assignees,
  }) : super(task: task, assignees: assignees);
}

final class TaskEditSubmitting extends TaskEditState {
  const TaskEditSubmitting({
    required Task task,
    required List<TaskAssignee> assignees,
  }) : super(task: task, assignees: assignees);
}

final class TaskEditSuccess extends TaskEditState {
  final Task updatedTask;

  const TaskEditSuccess(
    this.updatedTask, {
    super.assignees,
  }) : super(task: updatedTask);

  @override
  List<Object?> get props => [updatedTask, assignees];
}

final class TaskEditError extends TaskEditState {
  final String message;

  const TaskEditError(
    this.message, {
    super.task,
    super.assignees,
  });

  @override
  List<Object?> get props => [message, task, assignees];
}
