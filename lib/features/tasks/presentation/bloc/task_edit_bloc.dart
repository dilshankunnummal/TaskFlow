import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:taskflow/features/tasks/domain/entities/task_assignee.dart';
import 'package:taskflow/features/tasks/domain/usecases/get_assignees_usecase.dart';
import 'package:taskflow/features/tasks/domain/usecases/get_task_details_usecase.dart';
import 'package:taskflow/features/tasks/domain/usecases/update_task_usecase.dart';
import 'package:taskflow/features/tasks/presentation/bloc/task_edit_event.dart';
import 'package:taskflow/features/tasks/presentation/bloc/task_edit_state.dart';

@injectable
class TaskEditBloc extends Bloc<TaskEditEvent, TaskEditState> {
  final GetTaskDetailsUseCase _getTaskDetails;
  final GetAssigneesUseCase _getAssignees;
  final UpdateTaskUseCase _updateTask;

  TaskEditBloc(
    this._getTaskDetails,
    this._getAssignees,
    this._updateTask,
  ) : super(const TaskEditInitial()) {
    on<LoadTaskForEditing>(_onLoadTaskForEditing);
    on<UpdateTaskSubmitted>(_onUpdateTaskSubmitted);
  }

  Future<void> _onLoadTaskForEditing(
    LoadTaskForEditing event,
    Emitter<TaskEditState> emit,
  ) async {
    emit(TaskEditLoading(task: state.task, assignees: state.assignees));

    List<TaskAssignee> assignees = state.assignees;
    final assigneesResult = await _getAssignees();
    assigneesResult.fold(
      (_) {},
      (fetchedAssignees) {
        assignees = fetchedAssignees;
      },
    );

    final detailsResult = await _getTaskDetails(taskId: event.taskId);
    detailsResult.fold(
      (failure) => emit(TaskEditError(
        failure.message,
        task: state.task,
        assignees: assignees,
      )),
      (details) => emit(TaskEditLoaded(
        task: details.task,
        assignees: assignees,
      )),
    );
  }

  Future<void> _onUpdateTaskSubmitted(
    UpdateTaskSubmitted event,
    Emitter<TaskEditState> emit,
  ) async {
    final currentTask = state.task;
    if (currentTask == null) return;

    emit(TaskEditSubmitting(task: currentTask, assignees: state.assignees));

    final result = await _updateTask(
      id: event.id,
      projectId: event.projectId,
      title: event.title,
      description: event.description,
      status: event.status,
      priority: event.priority,
      assigneeId: event.assigneeId,
      dueDate: event.dueDate,
      createdAt: event.createdAt,
    );

    result.fold(
      (failure) => emit(TaskEditError(
        failure.message,
        task: currentTask,
        assignees: state.assignees,
      )),
      (task) => emit(TaskEditSuccess(task, assignees: state.assignees)),
    );
  }
}
