import 'package:hive/hive.dart';
import 'package:injectable/injectable.dart';
import 'package:taskflow/features/tasks/data/models/task_model.dart';

abstract class TasksLocalDataSource {
  Future<bool> hasCacheForProject(String projectId);

  Future<List<TaskModel>> getCachedTasksForProject(String projectId);

  Future<void> cacheTasksForProject(String projectId, List<TaskModel> tasks);

  Future<void> upsertTask(TaskModel task);

  Future<void> clearCacheForProject(String projectId);
}

@LazySingleton(as: TasksLocalDataSource)
class HiveTasksLocalDataSource implements TasksLocalDataSource {
  HiveTasksLocalDataSource(this._box);

  final Box<dynamic> _box;

  static const _taskKeyPrefix = 'task::';
  static const _seedMarkerPrefix = 'seed_marker::';

  String _taskKey(String taskId) => '$_taskKeyPrefix$taskId';

  String _seedMarkerKey(String projectId) => '$_seedMarkerPrefix$projectId';

  @override
  Future<bool> hasCacheForProject(String projectId) async {
    return _box.get(_seedMarkerKey(projectId)) == true;
  }

  @override
  Future<List<TaskModel>> getCachedTasksForProject(String projectId) async {
    return _box.values
        .whereType<Map>()
        .map((raw) => TaskModel.fromJson(Map<String, dynamic>.from(raw)))
        .where((model) => model.projectId == projectId)
        .toList();
  }

  @override
  Future<void> cacheTasksForProject(String projectId, List<TaskModel> tasks) async {
    for (final task in tasks) {
      await _box.put(_taskKey(task.id), task.toJson());
    }
    await _box.put(_seedMarkerKey(projectId), true);
  }

  @override
  Future<void> upsertTask(TaskModel task) async {
    await _box.put(_taskKey(task.id), task.toJson());
  }

  @override
  Future<void> clearCacheForProject(String projectId) async {
    final keysToRemove = _box.keys.where((key) {
      if (key is! String) {
        return false;
      }
      if (key == _seedMarkerKey(projectId)) {
        return true;
      }
      if (!key.startsWith(_taskKeyPrefix)) {
        return false;
      }
      final raw = _box.get(key);
      if (raw is! Map) {
        return false;
      }
      return raw['project_id'] == projectId;
    }).toList();

    await _box.deleteAll(keysToRemove);
  }
}