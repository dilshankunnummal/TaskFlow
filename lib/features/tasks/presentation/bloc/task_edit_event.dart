import 'package:equatable/equatable.dart';
import 'package:taskflow/features/tasks/domain/entities/task.dart';

sealed class TaskEditEvent extends Equatable {
  const TaskEditEvent();

  @override
  List<Object?> get props => [];
}

final class LoadTaskForEditing extends TaskEditEvent {
  final String taskId;

  const LoadTaskForEditing(this.taskId);

  @override
  List<Object?> get props => [taskId];
}

final class UpdateTaskSubmitted extends TaskEditEvent {
  final String id;
  final String projectId;
  final String title;
  final String description;
  final TaskStatus status;
  final TaskPriority priority;
  final String? assigneeId;
  final DateTime? dueDate;
  final DateTime createdAt;

  const UpdateTaskSubmitted({
    required this.id,
    required this.projectId,
    required this.title,
    required this.description,
    required this.status,
    required this.priority,
    required this.assigneeId,
    required this.dueDate,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        projectId,
        title,
        description,
        status,
        priority,
        assigneeId,
        dueDate,
        createdAt,
      ];
}
