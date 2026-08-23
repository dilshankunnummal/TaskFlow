import 'package:hive/hive.dart';
import 'package:injectable/injectable.dart';
import 'package:taskflow/core/error/failures.dart';
import 'package:taskflow/core/network/mock_network.dart';
import 'package:taskflow/features/projects/data/models/project_model.dart';

abstract class ProjectsLocalDataSource {
  Future<void> saveProject(ProjectModel project);

  Future<void> deleteProject(String projectId);

  Future<ProjectModel?> getProject(String projectId);

  Future<List<ProjectModel>> getProjectsForOrg(String orgId);
}

@LazySingleton(as: ProjectsLocalDataSource)
class HiveProjectsLocalDataSource implements ProjectsLocalDataSource {
  HiveProjectsLocalDataSource(this._box, this._network);

  final Box<dynamic> _box;
  final MockNetwork _network;

  @override
  Future<void> saveProject(ProjectModel project) async {
    await _network.simulateDelay();
    await _box.put(project.id, project.toJson());
  }

  @override
  Future<void> deleteProject(String projectId) async {
    await _network.simulateDelay();

    if (projectId == 'proj_debug_not_found') {
      throw const NotFoundFailure();
    }

    await _box.delete(projectId);
  }

  @override
  Future<ProjectModel?> getProject(String projectId) async {
    final raw = _box.get(projectId);
    if (raw == null) {
      return null;
    }
    return ProjectModel.fromJson(Map<String, dynamic>.from(raw as Map));
  }

  @override
  Future<List<ProjectModel>> getProjectsForOrg(String orgId) async {
    return _box.values
        .map((raw) => ProjectModel.fromJson(Map<String, dynamic>.from(raw as Map)))
        .where((model) => model.orgId == orgId)
        .toList();
  }
}