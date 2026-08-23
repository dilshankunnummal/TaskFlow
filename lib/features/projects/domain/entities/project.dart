import 'package:equatable/equatable.dart';

enum ProjectStatus { active, planning, onHold, archived }

class Project extends Equatable {
  final String id;
  final String orgId;
  final String name;
  final String description;
  final ProjectStatus status;
  final int taskCount;
  final DateTime createdAt;

  const Project({
    required this.id,
    required this.orgId,
    required this.name,
    required this.description,
    required this.status,
    required this.taskCount,
    required this.createdAt,
  });

  Project copyWith({
    String? id,
    String? orgId,
    String? name,
    String? description,
    ProjectStatus? status,
    int? taskCount,
    DateTime? createdAt,
  }) {
    return Project(
      id: id ?? this.id,
      orgId: orgId ?? this.orgId,
      name: name ?? this.name,
      description: description ?? this.description,
      status: status ?? this.status,
      taskCount: taskCount ?? this.taskCount,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [id, orgId, name, description, status, taskCount, createdAt];
}