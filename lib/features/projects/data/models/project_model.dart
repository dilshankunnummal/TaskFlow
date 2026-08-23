import 'package:taskflow/features/projects/domain/entities/project.dart';

class ProjectModel {
  final String id;
  final String orgId;
  final String name;
  final String description;
  final String status;
  final int taskCount;
  final String createdAt;

  const ProjectModel({
    required this.id,
    required this.orgId,
    required this.name,
    required this.description,
    required this.status,
    required this.taskCount,
    required this.createdAt,
  });

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    return ProjectModel(
      id: json['id'] as String,
      orgId: json['org_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      status: json['status'] as String,
      taskCount: json['task_count'] as int,
      createdAt: json['created_at'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'org_id': orgId,
      'name': name,
      'description': description,
      'status': status,
      'task_count': taskCount,
      'created_at': createdAt,
    };
  }

  factory ProjectModel.fromEntity(Project project) {
    return ProjectModel(
      id: project.id,
      orgId: project.orgId,
      name: project.name,
      description: project.description,
      status: _statusToString(project.status),
      taskCount: project.taskCount,
      createdAt: project.createdAt.toIso8601String(),
    );
  }

  Project toEntity() {
    return Project(
      id: id,
      orgId: orgId,
      name: name,
      description: description,
      status: _statusFromString(status),
      taskCount: taskCount,
      createdAt: DateTime.parse(createdAt),
    );
  }

  static ProjectStatus _statusFromString(String value) {
    switch (value) {
      case 'active':
        return ProjectStatus.active;
      case 'planning':
        return ProjectStatus.planning;
      case 'on_hold':
        return ProjectStatus.onHold;
      case 'archived':
        return ProjectStatus.archived;
      default:
        return ProjectStatus.active;
    }
  }

  static String _statusToString(ProjectStatus status) {
    switch (status) {
      case ProjectStatus.active:
        return 'active';
      case ProjectStatus.planning:
        return 'planning';
      case ProjectStatus.onHold:
        return 'on_hold';
      case ProjectStatus.archived:
        return 'archived';
    }
  }
}