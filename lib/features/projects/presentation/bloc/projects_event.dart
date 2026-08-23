import 'package:equatable/equatable.dart';
import 'package:taskflow/features/projects/presentation/bloc/projects_state.dart';

sealed class ProjectsEvent extends Equatable {
  const ProjectsEvent();

  @override
  List<Object?> get props => [];
}

class LoadProjects extends ProjectsEvent {
  const LoadProjects();
}

class RefreshProjects extends ProjectsEvent {
  const RefreshProjects();
}

class SearchProjects extends ProjectsEvent {
  final String query;

  const SearchProjects(this.query);

  @override
  List<Object?> get props => [query];
}

class SortProjects extends ProjectsEvent {
  final ProjectSortOption option;

  const SortProjects(this.option);

  @override
  List<Object?> get props => [option];
}