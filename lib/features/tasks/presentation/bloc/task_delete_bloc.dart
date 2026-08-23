import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:taskflow/features/tasks/domain/usecases/delete_task_usecase.dart';
import 'package:taskflow/features/tasks/presentation/bloc/task_delete_event.dart';
import 'package:taskflow/features/tasks/presentation/bloc/task_delete_state.dart';

@injectable
class TaskDeleteBloc extends Bloc<TaskDeleteEvent, TaskDeleteState> {
  final DeleteTaskUseCase _deleteTask;

  TaskDeleteBloc(this._deleteTask) : super(const TaskDeleteInitial()) {
    on<DeleteTaskRequested>(_onDeleteTaskRequested);
  }

  Future<void> _onDeleteTaskRequested(
    DeleteTaskRequested event,
    Emitter<TaskDeleteState> emit,
  ) async {
    emit(const TaskDeleteLoading());
    final result = await _deleteTask(event.taskId);
    result.fold(
      (failure) => emit(TaskDeleteError(failure.message)),
      (_) => emit(const TaskDeleteSuccess()),
    );
  }
}
