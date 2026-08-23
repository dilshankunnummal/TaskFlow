import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:taskflow/core/auth/current_session.dart';
import 'package:taskflow/core/error/failures.dart';
import 'package:taskflow/features/projects/domain/entities/project.dart';
import 'package:taskflow/features/projects/domain/usecases/delete_project_usecase.dart';
import 'package:taskflow/features/projects/domain/usecases/get_projects.dart';
import 'package:taskflow/features/projects/presentation/bloc/projects_event.dart';
import 'package:taskflow/features/projects/presentation/bloc/projects_state.dart';

@injectable
class ProjectsBloc extends Bloc<ProjectsEvent, ProjectsState> {
  final GetProjects _getProjects;
  final DeleteProjectUseCase _deleteProject;
  final CurrentSession _currentSession;

  ProjectsBloc(this._getProjects, this._deleteProject, this._currentSession)
      : super(const ProjectsInitial()) {
    on<LoadProjects>(_onLoadProjects);
    on<RefreshProjects>(_onRefreshProjects);
    on<SearchProjects>(_onSearchProjects);
    on<SortProjects>(_onSortProjects);
    on<DeleteProject>(_onDeleteProject);
  }

  Future<void> _onLoadProjects(LoadProjects event, Emitter<ProjectsState> emit) async {
    emit(const ProjectsLoading());
    await _fetchAndEmit(emit);
  }

  Future<void> _onRefreshProjects(RefreshProjects event, Emitter<ProjectsState> emit) async {
    final current = _currentQueryAndSort();
    await _fetchAndEmit(emit, query: current.$1, sortOption: current.$2);
  }

  Future<void> _onDeleteProject(DeleteProject event, Emitter<ProjectsState> emit) async {
    final current = _currentQueryAndSort();

    emit(ProjectDeleteInProgress(event.projectId));

    final result = await _deleteProject(projectId: event.projectId);

    await result.fold(
          (failure) async {
        emit(ProjectDeleteFailure(event.projectId, failure.message));
        await _fetchAndEmit(emit, query: current.$1, sortOption: current.$2);
      },
          (_) async {
        emit(ProjectDeleteSuccess(event.projectId));
        await _fetchAndEmit(emit, query: current.$1, sortOption: current.$2);
      },
    );
  }

  (String, ProjectSortOption) _currentQueryAndSort() {
    final current = state;
    if (current is ProjectsSuccess) {
      return (current.query, current.sortOption);
    }
    return ('', ProjectSortOption.newest);
  }

  Future<void> _fetchAndEmit(
      Emitter<ProjectsState> emit, {
        String query = '',
        ProjectSortOption sortOption = ProjectSortOption.newest,
      }) async {
    final orgId = await _currentSession.currentOrgId;
    if (orgId == null || orgId.isEmpty) {
      emit(const ProjectsError('No active organization found for this session'));
      return;
    }

    final result = await _getProjects(orgId: orgId);

    result.fold(
          (failure) {
        if (failure is OfflineFailure) {
          final cached = failure.cachedData as List<Project>?;
          if (cached != null && cached.isNotEmpty) {
            final visible = _applySearchAndSort(cached, query, sortOption);
            emit(ProjectsSuccess(
              allProjects: cached,
              visibleProjects: visible,
              query: query,
              sortOption: sortOption,
              isStale: true,
            ));
          } else {
            emit(ProjectsError(failure.message));
          }
        } else {
          emit(ProjectsError(failure.message));
        }
      },
          (projects) {
        if (projects.isEmpty) {
          emit(const ProjectsEmpty());
          return;
        }
        final visible = _applySearchAndSort(projects, query, sortOption);
        emit(ProjectsSuccess(
          allProjects: projects,
          visibleProjects: visible,
          query: query,
          sortOption: sortOption,
        ));
      },
    );
  }

  void _onSearchProjects(SearchProjects event, Emitter<ProjectsState> emit) {
    final current = state;
    if (current is! ProjectsSuccess) return;
    final visible = _applySearchAndSort(current.allProjects, event.query, current.sortOption);
    emit(current.copyWith(query: event.query, visibleProjects: visible));
  }

  void _onSortProjects(SortProjects event, Emitter<ProjectsState> emit) {
    final current = state;
    if (current is! ProjectsSuccess) return;
    final visible = _applySearchAndSort(current.allProjects, current.query, event.option);
    emit(current.copyWith(sortOption: event.option, visibleProjects: visible));
  }

  List<Project> _applySearchAndSort(List<Project> source, String query, ProjectSortOption sortOption) {
    final normalizedQuery = query.trim().toLowerCase();
    final filtered = normalizedQuery.isEmpty
        ? List<Project>.from(source)
        : source
        .where((project) =>
    project.name.toLowerCase().contains(normalizedQuery) ||
        project.description.toLowerCase().contains(normalizedQuery))
        .toList();

    filtered.sort((a, b) {
      switch (sortOption) {
        case ProjectSortOption.newest:
          return b.createdAt.compareTo(a.createdAt);
        case ProjectSortOption.oldest:
          return a.createdAt.compareTo(b.createdAt);
        case ProjectSortOption.alphabetical:
          return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      }
    });

    return filtered;
  }
}