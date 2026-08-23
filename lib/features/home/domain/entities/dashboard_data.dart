import 'package:equatable/equatable.dart';
import 'package:taskflow/features/auth/domain/entities/user_entity.dart';
import 'package:taskflow/features/home/domain/entities/activity_item_entity.dart';
import 'package:taskflow/features/home/domain/entities/dashboard_summary.dart';

final class DashboardData extends Equatable {
  const DashboardData({
    required this.user,
    required this.organizationName,
    required this.summary,
    required this.recentActivity,
  });

  final UserEntity user;
  final String organizationName;
  final DashboardSummary summary;
  final List<ActivityItemEntity> recentActivity;

  bool get hasSummaryData => summary.totalProjects > 0 || summary.totalTasks > 0;

  @override
  List<Object?> get props => [user, organizationName, summary, recentActivity];
}
