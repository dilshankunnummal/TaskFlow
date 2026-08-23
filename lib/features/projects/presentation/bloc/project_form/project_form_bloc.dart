import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:taskflow/core/auth/current_session.dart';
import 'package:taskflow/core/error/failures.dart';
import 'package:taskflow/features/projects/domain/usecases/create_project_usecase.dart';
import 'package:taskflow/features/projects/domain/usecases/delete_project_usecase.dart';
import 'package:taskflow/features/projects/domain/usecases/update_project_usecase.dart';
import 'package:taskflow/features/projects/presentation/bloc/project_form/project_form_event.dart';
import 'package:taskflow/features/projects/presentation/bloc/project_form/project_form_state.dart';

@injectable
class ProjectFormBloc extends Bloc<ProjectFormEvent, ProjectFormState> {
  final CreateProjectUseCase _createProject;
  final UpdateProjectUseCase _updateProject;
  final DeleteProjectUseCase _deleteProject;
  final CurrentSession _session;

  ProjectFormBloc(
      this._createProject,
      this._updateProject,
      this._deleteProject,
      this._session,
      ) : super(const ProjectFormInitial()) {
    on<CreateProject>(_onCreateProject);
    on<UpdateProject>(_onUpdateProject);
    on<DeleteProject>(_onDeleteProject);
  }

  Future<void> _onCreateProject(CreateProject event, Emitter<ProjectFormState> emit) async {
    emit(const ProjectFormLoading());

    final orgId = await _session.currentOrgId;
    if (orgId == null || orgId.isEmpty) {
      emit(const ProjectFormError(message: 'No active organization found for this session'));
      return;
    }

    final result = await _createProject(
      orgId: orgId,
      name: event.name,
      description: event.description,
      status: event.status,
    );

    result.fold(
          (failure) => emit(_mapFailureToState(failure)),
          (project) => emit(ProjectFormSuccess(
        message: 'Project created successfully',
        project: project,
      )),
    );
  }

  Future<void> _onUpdateProject(UpdateProject event, Emitter<ProjectFormState> emit) async {
    emit(const ProjectFormLoading());

    final result = await _updateProject(project: event.project);

    result.fold(
          (failure) => emit(_mapFailureToState(failure)),
          (project) => emit(ProjectFormSuccess(
        message: 'Project updated successfully',
        project: project,
      )),
    );
  }

  Future<void> _onDeleteProject(DeleteProject event, Emitter<ProjectFormState> emit) async {
    emit(const ProjectFormLoading());

    final result = await _deleteProject(projectId: event.projectId);

    result.fold(
          (failure) => emit(_mapFailureToState(failure)),
          (_) => emit(const ProjectFormSuccess(message: 'Project deleted successfully')),
    );
  }

  ProjectFormState _mapFailureToState(Failure failure) {
    if (failure is ValidationFailure) {
      return ProjectFormError(validationErrors: [failure.message]);
    }
    if (failure is PermissionFailure) {
      return ProjectFormError(message: failure.message);
    }
    if (failure is NotFoundFailure) {
      return ProjectFormError(message: failure.message);
    }
    return ProjectFormError(message: failure.message);
  }
}