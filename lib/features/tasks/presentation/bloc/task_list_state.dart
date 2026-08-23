import 'package:equatable/equatable.dart';
import 'package:taskflow/features/tasks/domain/entities/task.dart';
import 'package:taskflow/features/tasks/presentation/bloc/task_filter.dart';

sealed class TaskListState extends Equatable {
  const TaskListState();

  @override
  List<Object?> get props => [];
}

class TaskListInitial extends TaskListState {
  const TaskListInitial();
}

class TaskListLoading extends TaskListState {
  const TaskListLoading();
}

class TaskListSuccess extends TaskListState {
  final List<Task> allTasks;
  final List<Task> tasks;
  final TaskFilter filter;
  final String query;
  final bool isStale;

  const TaskListSuccess({
    required this.allTasks,
    required this.tasks,
    this.filter = const TaskFilter(),
    this.query = '',
    this.isStale = false,
  });

  TaskListSuccess copyWith({
    List<Task>? allTasks,
    List<Task>? tasks,
    TaskFilter? filter,
    String? query,
    bool? isStale,
  }) {
    return TaskListSuccess(
      allTasks: allTasks ?? this.allTasks,
      tasks: tasks ?? this.tasks,
      filter: filter ?? this.filter,
      query: query ?? this.query,
      isStale: isStale ?? this.isStale,
    );
  }

  @override
  List<Object?> get props => [allTasks, tasks, filter, query, isStale];
}

class TaskListEmpty extends TaskListState {
  const TaskListEmpty();
}

class TaskListError extends TaskListState {
  final String message;

  const TaskListError(this.message);

  @override
  List<Object?> get props => [message];
}