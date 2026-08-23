import 'package:equatable/equatable.dart';
import 'package:taskflow/features/tasks/domain/entities/organization_member.dart';
import 'package:taskflow/features/tasks/domain/entities/task.dart';

sealed class TaskAssignmentState extends Equatable {
  const TaskAssignmentState();

  @override
  List<Object?> get props => [];
}

final class TaskAssignmentInitial extends TaskAssignmentState {
  const TaskAssignmentInitial();
}

final class TaskAssignmentLoading extends TaskAssignmentState {
  const TaskAssignmentLoading();
}

final class TaskAssignmentLoaded extends TaskAssignmentState {
  final List<OrganizationMember> members;
  final String? currentAssigneeId;

  const TaskAssignmentLoaded({
    required this.members,
    this.currentAssigneeId,
  });

  @override
  List<Object?> get props => [members, currentAssigneeId];
}

final class TaskAssignmentSuccess extends TaskAssignmentState {
  final Task task;

  const TaskAssignmentSuccess(this.task);

  @override
  List<Object?> get props => [task];
}

final class TaskAssignmentError extends TaskAssignmentState {
  final String message;

  const TaskAssignmentError(this.message);

  @override
  List<Object?> get props => [message];
}
