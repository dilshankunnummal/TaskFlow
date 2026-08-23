import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:taskflow/core/error/failures.dart';
import 'package:taskflow/features/projects/domain/entities/project_details.dart';
import 'package:taskflow/features/projects/domain/usecases/get_project_details_usecase.dart';
import 'package:taskflow/features/projects/presentation/bloc/project_details_event.dart';
import 'package:taskflow/features/projects/presentation/bloc/project_details_state.dart';

@injectable
class ProjectDetailsBloc extends Bloc<ProjectDetailsEvent, ProjectDetailsState> {
  final GetProjectDetailsUseCase _getProjectDetails;

  ProjectDetails? _lastSuccessfulDetails;

  ProjectDetailsBloc(this._getProjectDetails) : super(const ProjectDetailsInitial()) {
    on<LoadProjectDetails>(_onLoadProjectDetails);
    on<RefreshProjectDetails>(_onRefreshProjectDetails);
  }

  Future<void> _onLoadProjectDetails(LoadProjectDetails event, Emitter<ProjectDetailsState> emit) async {
    emit(const ProjectDetailsLoading());
    await _fetchAndEmit(event.projectId, emit);
  }

  Future<void> _onRefreshProjectDetails(RefreshProjectDetails event, Emitter<ProjectDetailsState> emit) async {
    await _fetchAndEmit(event.projectId, emit);
  }

  Future<void> _fetchAndEmit(String projectId, Emitter<ProjectDetailsState> emit) async {
    final result = await _getProjectDetails(projectId: projectId);

    result.fold(
      (failure) => _emitFailure(failure, emit),
      (details) {
        _lastSuccessfulDetails = details;
        emit(_buildStateFromDetails(details, isStale: false));
      },
    );
  }

  void _emitFailure(Failure failure, Emitter<ProjectDetailsState> emit) {
    final cached = _lastSuccessfulDetails;
    if (failure is OfflineFailure && cached != null) {
      emit(_buildStateFromDetails(cached, isStale: true));
      return;
    }
    emit(ProjectDetailsError(failure.message));
  }

  ProjectDetailsState _buildStateFromDetails(ProjectDetails details, {required bool isStale}) {
    if (details.tasks.isEmpty) {
      return ProjectDetailsEmpty(project: details.project, isStale: isStale);
    }
    return ProjectDetailsSuccess(
      project: details.project,
      tasks: details.tasks,
      taskSummary: TaskSummary.fromTasks(details.tasks),
      isStale: isStale,
    );
  }
}
