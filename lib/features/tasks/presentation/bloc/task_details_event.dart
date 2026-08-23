import 'package:equatable/equatable.dart';

sealed class TaskDetailsEvent extends Equatable {
  const TaskDetailsEvent();

  @override
  List<Object?> get props => [];
}

class LoadTaskDetails extends TaskDetailsEvent {
  final String taskId;

  const LoadTaskDetails(this.taskId);

  @override
  List<Object?> get props => [taskId];
}

class RefreshTaskDetails extends TaskDetailsEvent {
  final String taskId;

  const RefreshTaskDetails(this.taskId);

  @override
  List<Object?> get props => [taskId];
}
