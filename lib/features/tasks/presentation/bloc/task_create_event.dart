import 'package:equatable/equatable.dart';
import 'package:taskflow/features/tasks/domain/entities/task.dart';

sealed class TaskCreateEvent extends Equatable {
  const TaskCreateEvent();

  @override
  List<Object?> get props => [];
}

class LoadAssignees extends TaskCreateEvent {
  const LoadAssignees();
}

class CreateTaskSubmitted extends TaskCreateEvent {
  final String projectId;
  final String title;
  final String description;
  final TaskStatus status;
  final TaskPriority priority;
  final String? assigneeId;
  final DateTime? dueDate;

  const CreateTaskSubmitted({
    required this.projectId,
    required this.title,
    required this.description,
    required this.status,
    required this.priority,
    required this.assigneeId,
    required this.dueDate,
  });

  @override
  List<Object?> get props => [
        projectId,
        title,
        description,
        status,
        priority,
        assigneeId,
        dueDate,
      ];
}
