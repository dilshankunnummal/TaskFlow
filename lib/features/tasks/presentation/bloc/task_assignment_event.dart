import 'package:equatable/equatable.dart';

sealed class TaskAssignmentEvent extends Equatable {
  const TaskAssignmentEvent();

  @override
  List<Object?> get props => [];
}

final class LoadOrganizationMembers extends TaskAssignmentEvent {
  final String organizationId;
  final String? projectId;
  final String? currentAssigneeId;

  const LoadOrganizationMembers({
    this.organizationId = '',
    this.projectId,
    this.currentAssigneeId,
  });

  @override
  List<Object?> get props => [organizationId, projectId, currentAssigneeId];
}

final class AssignUserToTask extends TaskAssignmentEvent {
  final String taskId;
  final String userId;

  const AssignUserToTask({
    required this.taskId,
    required this.userId,
  });

  @override
  List<Object?> get props => [taskId, userId];
}

final class RemoveUserFromTask extends TaskAssignmentEvent {
  final String taskId;

  const RemoveUserFromTask(this.taskId);

  @override
  List<Object?> get props => [taskId];
}
