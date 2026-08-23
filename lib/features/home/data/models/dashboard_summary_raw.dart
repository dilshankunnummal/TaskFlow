import 'package:taskflow/features/home/data/models/activity_item_model.dart';

final class DashboardSummaryRaw {
  const DashboardSummaryRaw({
    required this.organizationName,
    required this.totalProjects,
    required this.totalTasks,
    required this.tasksInProgress,
    required this.completedTasks,
    required this.recentActivity,
  });

  final String organizationName;
  final int totalProjects;
  final int totalTasks;
  final int tasksInProgress;
  final int completedTasks;
  final List<ActivityItemModel> recentActivity;
}
