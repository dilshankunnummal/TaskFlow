import 'package:equatable/equatable.dart';

sealed class TaskDeleteState extends Equatable {
  const TaskDeleteState();

  @override
  List<Object?> get props => [];
}

final class TaskDeleteInitial extends TaskDeleteState {
  const TaskDeleteInitial();
}

final class TaskDeleteLoading extends TaskDeleteState {
  const TaskDeleteLoading();
}

final class TaskDeleteSuccess extends TaskDeleteState {
  const TaskDeleteSuccess();
}

final class TaskDeleteError extends TaskDeleteState {
  final String message;

  const TaskDeleteError(this.message);

  @override
  List<Object?> get props => [message];
}
