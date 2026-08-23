import 'package:equatable/equatable.dart';

sealed class TaskDeleteEvent extends Equatable {
  const TaskDeleteEvent();

  @override
  List<Object?> get props => [];
}

final class DeleteTaskRequested extends TaskDeleteEvent {
  final String taskId;

  const DeleteTaskRequested(this.taskId);

  @override
  List<Object?> get props => [taskId];
}
