import 'package:equatable/equatable.dart';
import 'package:taskflow/features/tasks/domain/entities/task.dart';
import 'package:taskflow/features/tasks/domain/entities/task_assignee.dart';
import 'package:taskflow/features/tasks/domain/entities/task_comment.dart';

class TaskDetails extends Equatable {
  final Task task;

  final TaskAssignee? assignee;

  final List<TaskComment> comments;

  const TaskDetails({
    required this.task,
    required this.assignee,
    required this.comments,
  });

  bool get hasAssignee => assignee != null;
  bool get hasComments => comments.isNotEmpty;

  @override
  List<Object?> get props => [task, assignee, comments];
}
