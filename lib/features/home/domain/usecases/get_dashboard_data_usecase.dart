import 'package:taskflow/core/error/result.dart';
import 'package:taskflow/features/home/domain/entities/dashboard_data.dart';
import 'package:taskflow/features/home/domain/repositories/home_repository.dart';

class GetDashboardDataUseCase {
  const GetDashboardDataUseCase(this._repository);

  final HomeRepository _repository;

  Future<Result<DashboardData>> call() {
    return _repository.getDashboardData();
  }
}
