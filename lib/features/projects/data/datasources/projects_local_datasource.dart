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

  Future<Set<String>> getDeletedProjectIds();
}

@LazySingleton(as: ProjectsLocalDataSource)
class HiveProjectsLocalDataSource implements ProjectsLocalDataSource {
  HiveProjectsLocalDataSource(this._box, this._network);

  final Box<dynamic> _box;
  final MockNetwork _network;

  static const _deletedPrefix = 'deleted::';

  String _deletedKey(String projectId) => '$_deletedPrefix$projectId';

  @override
  Future<void> saveProject(ProjectModel project) async {
    await _network.simulateDelay();
    await _box.delete(_deletedKey(project.id));
    await _box.put(project.id, project.toJson());
  }

  @override
  Future<void> deleteProject(String projectId) async {
    await _network.simulateDelay();

    if (projectId == 'proj_debug_not_found') {
      throw const NotFoundFailure();
    }

    await _box.delete(projectId);
    await _box.put(_deletedKey(projectId), true);
  }

  @override
  Future<ProjectModel?> getProject(String projectId) async {
    final raw = _box.get(projectId);
    if (raw == null || raw is! Map) {
      return null;
    }
    return ProjectModel.fromJson(Map<String, dynamic>.from(raw));
  }

  @override
  Future<List<ProjectModel>> getProjectsForOrg(String orgId) async {
    return _box.values
        .whereType<Map>()
        .map((raw) => ProjectModel.fromJson(Map<String, dynamic>.from(raw)))
        .where((model) => model.orgId == orgId)
        .toList();
  }

  @override
  Future<Set<String>> getDeletedProjectIds() async {
    final deleted = <String>{};
    for (final key in _box.keys) {
      if (key is String && key.startsWith(_deletedPrefix)) {
        deleted.add(key.substring(_deletedPrefix.length));
      }
    }
    return deleted;
  }
}