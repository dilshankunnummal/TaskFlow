import 'package:equatable/equatable.dart';

final class DashboardSummary extends Equatable {
  const DashboardSummary({
    required this.totalProjects,
    required this.totalTasks,
    required this.tasksInProgress,
    required this.completedTasks,
  });

  final int totalProjects;
  final int totalTasks;
  final int tasksInProgress;
  final int completedTasks;

  @override
  List<Object?> get props => [totalProjects, totalTasks, tasksInProgress, completedTasks];
}
