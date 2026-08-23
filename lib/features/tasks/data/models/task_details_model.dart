import 'package:taskflow/features/tasks/data/models/task_assignee_model.dart';
import 'package:taskflow/features/tasks/data/models/task_comment_model.dart';
import 'package:taskflow/features/tasks/data/models/task_model.dart';
import 'package:taskflow/features/tasks/domain/entities/task_details.dart';

class TaskDetailsModel {
  final TaskModel task;
  final TaskAssigneeModel? assignee;
  final List<TaskCommentModel> comments;

  const TaskDetailsModel({
    required this.task,
    required this.assignee,
    required this.comments,
  });

  TaskDetails toEntity() {
    return TaskDetails(
      task: task.toEntity(),
      assignee: assignee?.toEntity(),
      comments: comments.map((c) => c.toEntity()).toList(),
    );
  }
}
