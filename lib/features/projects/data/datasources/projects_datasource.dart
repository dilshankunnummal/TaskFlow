import 'package:injectable/injectable.dart';
import 'package:taskflow/core/data/mock_json_data_source.dart';
import 'package:taskflow/core/error/failures.dart';
import 'package:taskflow/core/network/mock_network.dart';
import 'package:taskflow/features/projects/data/models/project_model.dart';

abstract class ProjectsDataSource {
  Future<List<ProjectModel>> getProjects({required String orgId});
}

@LazySingleton(as: ProjectsDataSource)
class MockProjectsDataSource implements ProjectsDataSource {
  final MockJsonDataSource _jsonDataSource;
  final MockNetwork _network;

  MockProjectsDataSource(this._jsonDataSource, this._network);

  @override
  Future<List<ProjectModel>> getProjects({required String orgId}) async {
    await _network.simulateDelay();

    if (!_network.isOnline) {
      throw const OfflineFailure(null);
    }

    if (orgId == 'org_debug_timeout') {
      throw const TimeoutFailure();
    }

    if (orgId == 'org_debug_not_found') {
      throw const NotFoundFailure();
    }

    if (orgId.trim().isEmpty) {
      throw const ValidationFailure('orgId must not be empty');
    }

    final rows = await _jsonDataSource.section('projects');
    return rows
        .where((row) => row['org_id'] == orgId)
        .map(ProjectModel.fromJson)
        .toList();
  }
}