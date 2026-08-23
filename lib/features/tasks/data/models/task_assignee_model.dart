import 'package:taskflow/features/tasks/domain/entities/task_assignee.dart';

class TaskAssigneeModel {
  final String id;
  final String name;
  final String email;
  final String? avatarUrl;

  const TaskAssigneeModel({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
  });

  factory TaskAssigneeModel.fromJson(Map<String, dynamic> json) {
    return TaskAssigneeModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      avatarUrl: json['avatar_url'] as String?,
    );
  }

  TaskAssignee toEntity() {
    return TaskAssignee(
      id: id,
      name: name,
      email: email,
      avatarUrl: avatarUrl,
    );
  }
}
