import 'package:equatable/equatable.dart';

enum ProjectTaskStatus { todo, inProgress, review, done }

enum ProjectTaskPriority { low, medium, high, urgent }

class ProjectTask extends Equatable {
  final String id;
  final String projectId;
  final String title;
  final String description;
  final ProjectTaskStatus status;
  final ProjectTaskPriority priority;
  final String? assigneeId;
  final DateTime? dueDate;
  final DateTime createdAt;

  const ProjectTask({
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

  ProjectTask copyWith({
    String? id,
    String? projectId,
    String? title,
    String? description,
    ProjectTaskStatus? status,
    ProjectTaskPriority? priority,
    String? assigneeId,
    DateTime? dueDate,
    DateTime? createdAt,
  }) {
    return ProjectTask(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      assigneeId: assigneeId ?? this.assigneeId,
      dueDate: dueDate ?? this.dueDate,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    projectId,
    title,
    description,
    status,
    priority,
    assigneeId,
    dueDate,
    createdAt,
  ];
}