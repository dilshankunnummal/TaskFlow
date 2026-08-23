import 'package:equatable/equatable.dart';
import 'package:taskflow/features/tasks/domain/entities/task.dart';
import 'package:taskflow/features/tasks/domain/entities/task_assignee.dart';

sealed class TaskCreateState extends Equatable {
  final List<TaskAssignee> assignees;

  const TaskCreateState({this.assignees = const []});

  @override
  List<Object?> get props => [assignees];
}

class TaskCreateInitial extends TaskCreateState {
  const TaskCreateInitial({super.assignees});
}

class TaskCreateLoading extends TaskCreateState {
  const TaskCreateLoading({super.assignees});
}

class TaskCreateSuccess extends TaskCreateState {
  final Task task;

  const TaskCreateSuccess(this.task, {super.assignees});

  @override
  List<Object?> get props => [task, assignees];
}

class TaskCreateError extends TaskCreateState {
  final String message;

  const TaskCreateError(this.message, {super.assignees});

  @override
  List<Object?> get props => [message, assignees];
}
