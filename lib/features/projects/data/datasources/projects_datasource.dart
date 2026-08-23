import 'package:injectable/injectable.dart';
import 'package:taskflow/core/data/mock_json_data_source.dart';
import 'package:taskflow/core/error/failures.dart';
import 'package:taskflow/core/network/mock_network.dart';
import 'package:taskflow/features/projects/data/models/project_model.dart';
import 'package:taskflow/features/projects/data/models/project_task_model.dart';

abstract class ProjectsDataSource {
  Future<List<ProjectModel>> getProjects({required String orgId});

  Future<ProjectModel> getProjectById({required String projectId});

  Future<List<ProjectTaskModel>> getProjectTasks({required String projectId});
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

  @override
  Future<ProjectModel> getProjectById({required String projectId}) async {
    await _network.simulateDelay();

    if (!_network.isOnline) {
      throw const OfflineFailure(null);
    }

    if (projectId == 'proj_debug_timeout') {
      throw const TimeoutFailure();
    }

    if (projectId == 'proj_debug_not_found') {
      throw const NotFoundFailure();
    }

    if (projectId.trim().isEmpty) {
      throw const ValidationFailure('projectId must not be empty');
    }

    final rows = await _jsonDataSource.section('projects');
    final row = rows.firstWhere(
      (candidate) => candidate['id'] == projectId,
      orElse: () => const <String, dynamic>{},
    );

    if (row.isEmpty) {
      throw const NotFoundFailure();
    }

    return ProjectModel.fromJson(row);
  }

  @override
  Future<List<ProjectTaskModel>> getProjectTasks({required String projectId}) async {
    await _network.simulateDelay();

    if (!_network.isOnline) {
      throw const OfflineFailure(null);
    }

    if (projectId == 'proj_debug_timeout') {
      throw const TimeoutFailure();
    }

    if (projectId == 'proj_debug_not_found') {
      throw const NotFoundFailure();
    }

    if (projectId.trim().isEmpty) {
      throw const ValidationFailure('projectId must not be empty');
    }

    final rows = await _jsonDataSource.section('tasks');
    return rows
        .where((row) => row['project_id'] == projectId)
        .map(ProjectTaskModel.fromJson)
        .toList();
  }
}