import 'package:dartz/dartz.dart' hide Task;
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:taskflow/core/error/failures.dart';
import 'package:taskflow/core/utils/logger.dart';
import 'package:taskflow/features/tasks/domain/entities/task_details.dart';
import 'package:taskflow/features/tasks/domain/usecases/get_task_details_usecase.dart';
import 'package:taskflow/features/tasks/presentation/bloc/task_details_event.dart';
import 'package:taskflow/features/tasks/presentation/bloc/task_details_state.dart';

@injectable
class TaskDetailsBloc extends Bloc<TaskDetailsEvent, TaskDetailsState> {
  final GetTaskDetailsUseCase _getTaskDetails;

  TaskDetailsBloc(this._getTaskDetails) : super(const TaskDetailsInitial()) {
    on<LoadTaskDetails>(_onLoadTaskDetails);
    on<RefreshTaskDetails>(_onRefreshTaskDetails);
  }

  Future<void> _onLoadTaskDetails(
      LoadTaskDetails event,
      Emitter<TaskDetailsState> emit,
      ) async {
    emit(const TaskDetailsLoading());
    _log('LoadTaskDetails requested taskId=${event.taskId}');
    final result = await _getTaskDetails(taskId: event.taskId);
    _emitResult(event.taskId, 'LoadTaskDetails', result, emit);
  }

  Future<void> _onRefreshTaskDetails(
      RefreshTaskDetails event,
      Emitter<TaskDetailsState> emit,
      ) async {
    _log('RefreshTaskDetails requested taskId=${event.taskId}');
    final result = await _getTaskDetails(taskId: event.taskId);
    _emitResult(event.taskId, 'RefreshTaskDetails', result, emit);
  }

  void _emitResult(
      String taskId,
      String source,
      Either<Failure, TaskDetails> result,
      Emitter<TaskDetailsState> emit,
      ) {
    result.fold(
          (failure) {
        _log(
          'TaskDetailsBloc[$source] taskId=$taskId failed with '
              '${failure.runtimeType}: ${failure.message}',
        );
        if (failure is OfflineFailure) {
          final cached = failure.cachedData as TaskDetails?;
          if (cached != null) {
            _log(
              'TaskDetailsBloc[$source] taskId=$taskId recovered from '
                  'offline cache, showing stale data',
            );
            emit(TaskDetailsSuccess(
              task: cached.task,
              assignee: cached.assignee,
              comments: cached.comments,
              isStale: true,
            ));
            return;
          }
        }
        emit(TaskDetailsError(failure.message));
      },
          (taskDetails) {
        _log(
          'TaskDetailsBloc[$source] taskId=$taskId succeeded, '
              'task.id=${taskDetails.task.id}',
        );
        emit(TaskDetailsSuccess(
          task: taskDetails.task,
          assignee: taskDetails.assignee,
          comments: taskDetails.comments,
        ));
      },
    );
  }

  void _log(String message) {
    AppLogger.error(message);
    if (kDebugMode) {
      debugPrint('[TaskDetailsBloc] $message');
    }
  }
}