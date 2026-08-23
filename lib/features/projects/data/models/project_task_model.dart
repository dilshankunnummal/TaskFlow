import 'package:taskflow/features/projects/domain/entities/project_task.dart';

class ProjectTaskModel {
  final String id;
  final String projectId;
  final String title;
  final String description;
  final String status;
  final String priority;
  final String? assigneeId;
  final String? dueDate;
  final String createdAt;

  const ProjectTaskModel({
    required this.id,
    required this.projectId,
    required this.title,
    required this.description,
    required this.status,
    required this.priority,
    required this.assigneeId,
    required this.dueDate,
    required this.createdAt,
  });

  factory ProjectTaskModel.fromJson(Map<String, dynamic> json) {
    return ProjectTaskModel(
      id: json['id'] as String,
      projectId: json['project_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      status: json['status'] as String,
      priority: json['priority'] as String,
      assigneeId: json['assignee_id'] as String?,
      dueDate: json['due_date'] as String?,
      createdAt: json['created_at'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'project_id': projectId,
      'title': title,
      'description': description,
      'status': status,
      'priority': priority,
      'assignee_id': assigneeId,
      'due_date': dueDate,
      'created_at': createdAt,
    };
  }

  ProjectTask toEntity() {
    return ProjectTask(
      id: id,
      projectId: projectId,
      title: title,
      description: description,
      status: _statusFromString(status),
      priority: _priorityFromString(priority),
      assigneeId: assigneeId,
      dueDate: dueDate != null ? DateTime.parse(dueDate!) : null,
      createdAt: DateTime.parse(createdAt),
    );
  }

  static ProjectTaskStatus _statusFromString(String value) {
    switch (value) {
      case 'todo':
        return ProjectTaskStatus.todo;
      case 'in_progress':
        return ProjectTaskStatus.inProgress;
      case 'review':
        return ProjectTaskStatus.review;
      case 'done':
        return ProjectTaskStatus.done;
      default:
        return ProjectTaskStatus.todo;
    }
  }

  static ProjectTaskPriority _priorityFromString(String value) {
    switch (value) {
      case 'low':
        return ProjectTaskPriority.low;
      case 'medium':
        return ProjectTaskPriority.medium;
      case 'high':
        return ProjectTaskPriority.high;
      case 'urgent':
        return ProjectTaskPriority.urgent;
      default:
        return ProjectTaskPriority.medium;
    }
  }
}