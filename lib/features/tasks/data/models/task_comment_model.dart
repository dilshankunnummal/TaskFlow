import 'package:taskflow/features/tasks/domain/entities/task_comment.dart';

class TaskCommentModel {
  final String id;
  final String taskId;
  final String authorId;
  final String authorName;
  final String body;
  final DateTime createdAt;

  const TaskCommentModel({
    required this.id,
    required this.taskId,
    required this.authorId,
    required this.authorName,
    required this.body,
    required this.createdAt,
  });

  factory TaskCommentModel.fromJson(
    Map<String, dynamic> json, {
    required String authorName,
  }) {
    return TaskCommentModel(
      id: json['id'] as String,
      taskId: json['task_id'] as String,
      authorId: json['author_id'] as String,
      authorName: authorName,
      body: json['body'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  TaskComment toEntity() {
    return TaskComment(
      id: id,
      taskId: taskId,
      authorId: authorId,
      authorName: authorName,
      body: body,
      createdAt: createdAt,
    );
  }
}
