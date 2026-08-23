import 'package:equatable/equatable.dart';
import 'package:taskflow/features/tasks/presentation/bloc/task_filter.dart';

sealed class TaskListEvent extends Equatable {
  const TaskListEvent();

  @override
  List<Object?> get props => [];
}

class LoadTasks extends TaskListEvent {
  final String projectId;

  const LoadTasks(this.projectId);

  @override
  List<Object?> get props => [projectId];
}

class RefreshTasks extends TaskListEvent {
  final String projectId;

  const RefreshTasks(this.projectId);

  @override
  List<Object?> get props => [projectId];
}

class FilterTasks extends TaskListEvent {
  final TaskFilter filter;

  const FilterTasks(this.filter);

  @override
  List<Object?> get props => [filter];
}

class SearchTasks extends TaskListEvent {
  final String query;

  const SearchTasks(this.query);

  @override
  List<Object?> get props => [query];
}