import 'package:taskflow/core/error/failures.dart';
import 'package:taskflow/core/error/result.dart';
import 'package:taskflow/features/auth/domain/repositories/auth_repository.dart';
import 'package:taskflow/features/home/data/datasources/home_mock_datasource.dart';
import 'package:taskflow/features/home/domain/entities/dashboard_data.dart';
import 'package:taskflow/features/home/domain/entities/dashboard_summary.dart';
import 'package:taskflow/features/home/domain/repositories/home_repository.dart';

final class HomeRepositoryImpl implements HomeRepository {
  HomeRepositoryImpl(this._authRepository, this._dataSource);

  final AuthRepository _authRepository;
  final HomeMockDataSource _dataSource;

  @override
  Future<Result<DashboardData>> getDashboardData() async {
    final userResult = await _authRepository.getCurrentUser();

    if (userResult.isFailure) {
      return ResultFailure(userResult.failureOrNull ?? const UnknownFailure());
    }

    final user = userResult.valueOrNull;
    if (user == null) {
      return const ResultFailure(UnauthorizedFailure());
    }

    return Result.guard(() async {
      final raw = await _dataSource.getDashboardSummary(orgId: user.orgId);

      return DashboardData(
        user: user,
        organizationName: raw.organizationName,
        summary: DashboardSummary(
          totalProjects: raw.totalProjects,
          totalTasks: raw.totalTasks,
          tasksInProgress: raw.tasksInProgress,
          completedTasks: raw.completedTasks,
        ),
        recentActivity: raw.recentActivity.map((item) => item.toEntity()).toList(),
      );
    });
  }
}
