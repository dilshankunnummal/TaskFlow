import 'package:taskflow/core/error/result.dart';
import 'package:taskflow/features/home/domain/entities/dashboard_data.dart';

abstract interface class HomeRepository {
  Future<Result<DashboardData>> getDashboardData();
}
