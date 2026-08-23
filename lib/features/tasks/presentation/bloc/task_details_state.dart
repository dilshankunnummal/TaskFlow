import 'package:equatable/equatable.dart';
import 'package:taskflow/features/tasks/domain/entities/task.dart';
import 'package:taskflow/features/tasks/domain/entities/task_assignee.dart';
import 'package:taskflow/features/tasks/domain/entities/task_comment.dart';

sealed class TaskDetailsState extends Equatable {
  const TaskDetailsState();

  @override
  List<Object?> get props => [];
}

class TaskDetailsInitial extends TaskDetailsState {
  const TaskDetailsInitial();
}

class TaskDetailsLoading extends TaskDetailsState {
  const TaskDetailsLoading();
}

class TaskDetailsSuccess extends TaskDetailsState {
  final Task task;

  final TaskAssignee? assignee;

  final List<TaskComment> comments;

  final bool isStale;

  const TaskDetailsSuccess({
    required this.task,
    required this.assignee,
    required this.comments,
    this.isStale = false,
  });

  @override
  List<Object?> get props => [task, assignee, comments, isStale];
}

class TaskDetailsEmpty extends TaskDetailsState {
  const TaskDetailsEmpty();
}

class TaskDetailsError extends TaskDetailsState {
  final String message;

  const TaskDetailsError(this.message);

  @override
  List<Object?> get props => [message];
}
