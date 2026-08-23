import 'package:equatable/equatable.dart';

class TaskComment extends Equatable {
  final String id;
  final String taskId;
  final String authorId;
  final String authorName;
  final String body;
  final DateTime createdAt;

  const TaskComment({
    required this.id,
    required this.taskId,
    required this.authorId,
    required this.authorName,
    required this.body,
    required this.createdAt,
  });

  @override
  List<Object?> get props =>
      [id, taskId, authorId, authorName, body, createdAt];
}
