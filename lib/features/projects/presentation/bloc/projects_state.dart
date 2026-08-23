import 'package:equatable/equatable.dart';
import 'package:taskflow/features/projects/domain/entities/project.dart';

enum ProjectSortOption { newest, oldest, alphabetical }

sealed class ProjectsState extends Equatable {
  const ProjectsState();

  @override
  List<Object?> get props => [];
}

class ProjectsInitial extends ProjectsState {
  const ProjectsInitial();
}

class ProjectsLoading extends ProjectsState {
  const ProjectsLoading();
}

class ProjectsSuccess extends ProjectsState {
  final List<Project> allProjects;
  final List<Project> visibleProjects;
  final String query;
  final ProjectSortOption sortOption;
  final bool isStale;

  const ProjectsSuccess({
    required this.allProjects,
    required this.visibleProjects,
    required this.query,
    required this.sortOption,
    this.isStale = false,
  });

  ProjectsSuccess copyWith({
    List<Project>? allProjects,
    List<Project>? visibleProjects,
    String? query,
    ProjectSortOption? sortOption,
    bool? isStale,
  }) {
    return ProjectsSuccess(
      allProjects: allProjects ?? this.allProjects,
      visibleProjects: visibleProjects ?? this.visibleProjects,
      query: query ?? this.query,
      sortOption: sortOption ?? this.sortOption,
      isStale: isStale ?? this.isStale,
    );
  }

  @override
  List<Object?> get props => [allProjects, visibleProjects, query, sortOption, isStale];
}

class ProjectsEmpty extends ProjectsState {
  const ProjectsEmpty();
}

class ProjectsError extends ProjectsState {
  final String message;

  const ProjectsError(this.message);

  @override
  List<Object?> get props => [message];
}

class ProjectDeleteInProgress extends ProjectsState {
  final String projectId;

  const ProjectDeleteInProgress(this.projectId);

  @override
  List<Object?> get props => [projectId];
}

class ProjectDeleteSuccess extends ProjectsState {
  final String projectId;

  const ProjectDeleteSuccess(this.projectId);

  @override
  List<Object?> get props => [projectId];
}

class ProjectDeleteFailure extends ProjectsState {
  final String projectId;
  final String message;

  const ProjectDeleteFailure(this.projectId, this.message);

  @override
  List<Object?> get props => [projectId, message];
}