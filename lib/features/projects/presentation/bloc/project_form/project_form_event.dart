import 'package:equatable/equatable.dart';
import 'package:taskflow/features/projects/domain/entities/project.dart';

class ProjectFormEvent extends Equatable {
  const ProjectFormEvent();

  @override
  List<Object?> get props => [];
}

class CreateProject extends ProjectFormEvent {
  final String name;
  final String description;
  final ProjectStatus status;

  const CreateProject({
    required this.name,
    required this.description,
    this.status = ProjectStatus.planning,
  });

  @override
  List<Object?> get props => [name, description, status];
}

class UpdateProject extends ProjectFormEvent {
  final Project project;

  const UpdateProject(this.project);

  @override
  List<Object?> get props => [project];
}

class DeleteProject extends ProjectFormEvent {
  final String projectId;

  const DeleteProject(this.projectId);

  @override
  List<Object?> get props => [projectId];
}