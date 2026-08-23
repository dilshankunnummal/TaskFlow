import 'package:taskflow/features/tasks/domain/entities/task.dart';

class TaskModel {
  final String id;
  final String projectId;
  final String title;
  final String description;
  final String status;
  final String priority;
  final String? assigneeId;
  final String? dueDate;
  final String createdAt;

  const TaskModel({
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

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
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

  factory TaskModel.fromEntity(Task task) {
    return TaskModel(
      id: task.id,
      projectId: task.projectId,
      title: task.title,
      description: task.description,
      status: _statusToString(task.status),
      priority: _priorityToString(task.priority),
      assigneeId: task.assigneeId,
      dueDate: task.dueDate?.toIso8601String(),
      createdAt: task.createdAt.toIso8601String(),
    );
  }

  Task toEntity() {
    return Task(
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

  static TaskStatus _statusFromString(String value) {
    switch (value) {
      case 'todo':
        return TaskStatus.todo;
      case 'in_progress':
        return TaskStatus.inProgress;
      case 'review':
        return TaskStatus.review;
      case 'done':
        return TaskStatus.done;
      default:
        return TaskStatus.todo;
    }
  }

  static String _statusToString(TaskStatus status) {
    switch (status) {
      case TaskStatus.todo:
        return 'todo';
      case TaskStatus.inProgress:
        return 'in_progress';
      case TaskStatus.review:
        return 'review';
      case TaskStatus.done:
        return 'done';
    }
  }

  static TaskPriority _priorityFromString(String value) {
    switch (value) {
      case 'low':
        return TaskPriority.low;
      case 'medium':
        return TaskPriority.medium;
      case 'high':
        return TaskPriority.high;
      case 'urgent':
        return TaskPriority.urgent;
      default:
        return TaskPriority.medium;
    }
  }

  static String _priorityToString(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return 'low';
      case TaskPriority.medium:
        return 'medium';
      case TaskPriority.high:
        return 'high';
      case TaskPriority.urgent:
        return 'urgent';
    }
  }
}