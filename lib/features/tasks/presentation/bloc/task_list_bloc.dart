import 'package:dartz/dartz.dart' hide Task;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:taskflow/core/error/failures.dart';
import 'package:taskflow/features/tasks/domain/entities/task.dart';
import 'package:taskflow/features/tasks/domain/repositories/task_repository.dart';
import 'package:taskflow/features/tasks/domain/usecases/get_project_tasks_usecase.dart';
import 'package:taskflow/features/tasks/presentation/bloc/task_filter.dart';
import 'package:taskflow/features/tasks/presentation/bloc/task_list_event.dart';
import 'package:taskflow/features/tasks/presentation/bloc/task_list_state.dart';

@injectable
class TaskListBloc extends Bloc<TaskListEvent, TaskListState> {
  final GetProjectTasksUseCase _getProjectTasks;
  final TaskRepository _taskRepository;

  TaskListBloc(this._getProjectTasks, this._taskRepository) : super(const TaskListInitial()) {
    on<LoadTasks>(_onLoadTasks);
    on<RefreshTasks>(_onRefreshTasks);
    on<FilterTasks>(_onFilterTasks);
    on<SearchTasks>(_onSearchTasks);
  }

  Future<void> _onLoadTasks(LoadTasks event, Emitter<TaskListState> emit) async {
    emit(const TaskListLoading());

    final result = await _getProjectTasks(projectId: event.projectId);

    _emitResult(result, emit, filter: const TaskFilter(), query: '');
  }

  Future<void> _onRefreshTasks(RefreshTasks event, Emitter<TaskListState> emit) async {
    final current = state;
    final filter = current is TaskListSuccess ? current.filter : const TaskFilter();
    final query = current is TaskListSuccess ? current.query : '';

    final result = await _taskRepository.refreshTasks(projectId: event.projectId);

    _emitResult(result, emit, filter: filter, query: query);
  }

  void _onFilterTasks(FilterTasks event, Emitter<TaskListState> emit) {
    final current = state;
    if (current is! TaskListSuccess) return;

    final visible = _applyFilterAndSearch(current.allTasks, event.filter, current.query);
    emit(current.copyWith(filter: event.filter, tasks: visible));
  }

  void _onSearchTasks(SearchTasks event, Emitter<TaskListState> emit) {
    final current = state;
    if (current is! TaskListSuccess) return;

    final visible = _applyFilterAndSearch(current.allTasks, current.filter, event.query);
    emit(current.copyWith(query: event.query, tasks: visible));
  }

  void _emitResult(
      Either<Failure, List<Task>> result,
      Emitter<TaskListState> emit, {
        required TaskFilter filter,
        required String query,
      }) {
    result.fold(
          (failure) {
        if (failure is OfflineFailure) {
          final cached = failure.cachedData as List<Task>?;
          if (cached != null && cached.isNotEmpty) {
            final visible = _applyFilterAndSearch(cached, filter, query);
            emit(TaskListSuccess(
              allTasks: cached,
              tasks: visible,
              filter: filter,
              query: query,
              isStale: true,
            ));
            return;
          }
        }
        emit(TaskListError(failure.message));
      },
          (tasks) {
        if (tasks.isEmpty) {
          emit(const TaskListEmpty());
          return;
        }
        final visible = _applyFilterAndSearch(tasks, filter, query);
        emit(TaskListSuccess(allTasks: tasks, tasks: visible, filter: filter, query: query));
      },
    );
  }

  List<Task> _applyFilterAndSearch(List<Task> source, TaskFilter filter, String query) {
    var filtered = List<Task>.from(source);

    if (filter.statuses.isNotEmpty) {
      filtered = filtered.where((task) => filter.statuses.contains(task.status)).toList();
    }

    if (filter.priorities.isNotEmpty) {
      filtered = filtered.where((task) => filter.priorities.contains(task.priority)).toList();
    }

    if (filter.assigneeIds.isNotEmpty) {
      filtered = filtered
          .where((task) => task.assigneeId != null && filter.assigneeIds.contains(task.assigneeId))
          .toList();
    }

    final dueDateRange = filter.dueDateRange;
    if (dueDateRange != null) {
      filtered = filtered.where((task) => task.dueDate != null && dueDateRange.contains(task.dueDate!)).toList();
    }

    final normalizedQuery = query.trim().toLowerCase();
    if (normalizedQuery.isNotEmpty) {
      filtered = filtered.where((task) => task.title.toLowerCase().contains(normalizedQuery)).toList();
    }

    return filtered;
  }
}