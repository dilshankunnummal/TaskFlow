import 'package:taskflow/core/data/mock_json_loader.dart';
import 'package:taskflow/core/network/simulated_network.dart';
import 'package:taskflow/features/home/data/models/activity_item_model.dart';
import 'package:taskflow/features/home/data/models/dashboard_summary_raw.dart';

abstract interface class HomeMockDataSource {
  Future<DashboardSummaryRaw> getDashboardSummary({required String orgId});
}

final class HomeMockDataSourceImpl implements HomeMockDataSource {
  HomeMockDataSourceImpl(this._mockJsonLoader, this._simulatedNetwork);

  final MockJsonLoader _mockJsonLoader;
  final SimulatedNetwork _simulatedNetwork;

  static const String _statusDone = 'done';
  static const String _statusInProgress = 'in_progress';
  static const int _recentActivityLimit = 5;

  @override
  Future<DashboardSummaryRaw> getDashboardSummary({required String orgId}) async {
    await _simulatedNetwork.delay();

    final organizations = await _mockJsonLoader.section('organizations');
    final projects = await _mockJsonLoader.section('projects');
    final tasks = await _mockJsonLoader.section('tasks');

    final organization = organizations.firstWhere(
      (candidate) => candidate['id'] == orgId,
      orElse: () => const <String, dynamic>{},
    );
    final organizationName = organization['name'] as String? ?? 'Your organization';

    final orgProjects = projects.where((project) => project['org_id'] == orgId).toList();
    final orgProjectIds = orgProjects.map((project) => project['id'] as String).toSet();
    final orgTasks = tasks.where((task) => orgProjectIds.contains(task['project_id'] as String)).toList();

    final tasksInProgress = orgTasks.where((task) => task['status'] == _statusInProgress).length;
    final completedTasks = orgTasks.where((task) => task['status'] == _statusDone).length;

    final sortedTasks = [...orgTasks]..sort(
        (a, b) => DateTime.parse(b['created_at'] as String).compareTo(DateTime.parse(a['created_at'] as String)),
      );

    final recentActivity = sortedTasks.take(_recentActivityLimit).map((task) {
      final project = orgProjects.firstWhere(
        (candidate) => candidate['id'] == task['project_id'],
        orElse: () => const <String, dynamic>{'name': 'Unknown project'},
      );

      return ActivityItemModel(
        id: task['id'] as String,
        title: task['title'] as String,
        projectName: project['name'] as String? ?? 'Unknown project',
        status: task['status'] as String,
        timestamp: DateTime.parse(task['created_at'] as String),
      );
    }).toList();

    return DashboardSummaryRaw(
      organizationName: organizationName,
      totalProjects: orgProjects.length,
      totalTasks: orgTasks.length,
      tasksInProgress: tasksInProgress,
      completedTasks: completedTasks,
      recentActivity: recentActivity,
    );
  }
}
