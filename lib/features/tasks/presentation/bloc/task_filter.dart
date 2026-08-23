import 'package:equatable/equatable.dart';
import 'package:taskflow/features/tasks/domain/entities/task.dart';

class TaskDueDateRange extends Equatable {
  final DateTime start;
  final DateTime end;

  const TaskDueDateRange({required this.start, required this.end});

  bool contains(DateTime date) {
    final normalized = DateTime(date.year, date.month, date.day);
    final startDay = DateTime(start.year, start.month, start.day);
    final endDay = DateTime(end.year, end.month, end.day);
    return !normalized.isBefore(startDay) && !normalized.isAfter(endDay);
  }

  @override
  List<Object?> get props => [start, end];
}

class TaskFilter extends Equatable {
  final Set<TaskStatus> statuses;
  final Set<TaskPriority> priorities;
  final Set<String> assigneeIds;
  final TaskDueDateRange? dueDateRange;

  const TaskFilter({
    this.statuses = const {},
    this.priorities = const {},
    this.assigneeIds = const {},
    this.dueDateRange,
  });

  bool get isEmpty =>
      statuses.isEmpty && priorities.isEmpty && assigneeIds.isEmpty && dueDateRange == null;

  TaskFilter copyWith({
    Set<TaskStatus>? statuses,
    Set<TaskPriority>? priorities,
    Set<String>? assigneeIds,
    TaskDueDateRange? dueDateRange,
    bool clearDueDateRange = false,
  }) {
    return TaskFilter(
      statuses: statuses ?? this.statuses,
      priorities: priorities ?? this.priorities,
      assigneeIds: assigneeIds ?? this.assigneeIds,
      dueDateRange: clearDueDateRange ? null : (dueDateRange ?? this.dueDateRange),
    );
  }

  @override
  List<Object?> get props => [statuses, priorities, assigneeIds, dueDateRange];
}