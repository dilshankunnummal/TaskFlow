import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:taskflow/features/tasks/domain/usecases/assign_task_usecase.dart';
import 'package:taskflow/features/tasks/domain/usecases/get_organization_members_usecase.dart';
import 'package:taskflow/features/tasks/domain/usecases/unassign_task_usecase.dart';
import 'package:taskflow/features/tasks/presentation/bloc/task_assignment_event.dart';
import 'package:taskflow/features/tasks/presentation/bloc/task_assignment_state.dart';

@injectable
class TaskAssignmentBloc
    extends Bloc<TaskAssignmentEvent, TaskAssignmentState> {
  final GetOrganizationMembersUseCase _getOrganizationMembers;
  final AssignTaskUseCase _assignTask;
  final UnassignTaskUseCase _unassignTask;

  TaskAssignmentBloc(
    this._getOrganizationMembers,
    this._assignTask,
    this._unassignTask,
  ) : super(const TaskAssignmentInitial()) {
    on<LoadOrganizationMembers>(_onLoadOrganizationMembers);
    on<AssignUserToTask>(_onAssignUserToTask);
    on<RemoveUserFromTask>(_onRemoveUserFromTask);
  }

  Future<void> _onLoadOrganizationMembers(
    LoadOrganizationMembers event,
    Emitter<TaskAssignmentState> emit,
  ) async {
    emit(const TaskAssignmentLoading());
    final orgId = event.organizationId.isEmpty ? 'org_a1b2c3' : event.organizationId;
    final result = await _getOrganizationMembers(orgId);
    result.fold(
      (failure) => emit(TaskAssignmentError(failure.message)),
      (members) => emit(TaskAssignmentLoaded(
        members: members,
        currentAssigneeId: event.currentAssigneeId,
      )),
    );
  }

  Future<void> _onAssignUserToTask(
    AssignUserToTask event,
    Emitter<TaskAssignmentState> emit,
  ) async {
    emit(const TaskAssignmentLoading());
    final result =
        await _assignTask(taskId: event.taskId, userId: event.userId);
    result.fold(
      (failure) => emit(TaskAssignmentError(failure.message)),
      (task) => emit(TaskAssignmentSuccess(task)),
    );
  }

  Future<void> _onRemoveUserFromTask(
    RemoveUserFromTask event,
    Emitter<TaskAssignmentState> emit,
  ) async {
    emit(const TaskAssignmentLoading());
    final result = await _unassignTask(event.taskId);
    result.fold(
      (failure) => emit(TaskAssignmentError(failure.message)),
      (task) => emit(TaskAssignmentSuccess(task)),
    );
  }
}
