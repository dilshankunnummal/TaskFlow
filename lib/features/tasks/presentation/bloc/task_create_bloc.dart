import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:taskflow/core/error/failures.dart';
import 'package:taskflow/core/utils/logger.dart';
import 'package:taskflow/features/tasks/domain/usecases/create_task_usecase.dart';
import 'package:taskflow/features/tasks/domain/usecases/get_assignees_usecase.dart';
import 'package:taskflow/features/tasks/presentation/bloc/task_create_event.dart';
import 'package:taskflow/features/tasks/presentation/bloc/task_create_state.dart';

@injectable
class TaskCreateBloc extends Bloc<TaskCreateEvent, TaskCreateState> {
  final CreateTaskUseCase _createTask;
  final GetAssigneesUseCase _getAssignees;

  TaskCreateBloc(this._createTask, this._getAssignees)
      : super(const TaskCreateInitial()) {
    on<LoadAssignees>(_onLoadAssignees);
    on<CreateTaskSubmitted>(_onCreateTaskSubmitted);
  }

  Future<void> _onLoadAssignees(
      LoadAssignees event, Emitter<TaskCreateState> emit) async {
    final result = await _getAssignees();
    result.fold(
          (failure) {
        _logFailure('LoadAssignees', failure);
        emit(TaskCreateError(failure.message, assignees: state.assignees));
      },
          (assignees) => emit(TaskCreateInitial(assignees: assignees)),
    );
  }

  Future<void> _onCreateTaskSubmitted(
      CreateTaskSubmitted event, Emitter<TaskCreateState> emit) async {
    emit(TaskCreateLoading(assignees: state.assignees));

    final result = await _createTask(
      projectId: event.projectId,
      title: event.title,
      description: event.description,
      status: event.status,
      priority: event.priority,
      assigneeId: event.assigneeId,
      dueDate: event.dueDate,
    );

    result.fold(
          (failure) {
        _logFailure('CreateTaskSubmitted', failure);
        emit(TaskCreateError(failure.message, assignees: state.assignees));
      },
          (task) => emit(TaskCreateSuccess(task, assignees: state.assignees)),
    );
  }

  void _logFailure(String source, Failure failure) {
    final details = 'TaskCreateBloc[$source] emitted ${failure.runtimeType}: ${failure.message}';
    AppLogger.error(details);
    if (kDebugMode) {
      debugPrint(details);
    }
  }
}