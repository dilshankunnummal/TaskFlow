import 'package:equatable/equatable.dart';

sealed class ProjectDetailsEvent extends Equatable {
  const ProjectDetailsEvent();

  @override
  List<Object?> get props => [];
}

class LoadProjectDetails extends ProjectDetailsEvent {
  final String projectId;

  const LoadProjectDetails(this.projectId);

  @override
  List<Object?> get props => [projectId];
}

class RefreshProjectDetails extends ProjectDetailsEvent {
  final String projectId;

  const RefreshProjectDetails(this.projectId);

  @override
  List<Object?> get props => [projectId];
}
