import 'package:injectable/injectable.dart';
import 'package:taskflow/core/data/mock_json_data_source.dart';
import 'package:taskflow/core/error/failures.dart';
import 'package:taskflow/core/network/mock_network.dart';
import 'package:taskflow/features/tasks/data/models/task_model.dart';

abstract class TasksDataSource {
  Future<List<TaskModel>> getTasksByProject({required String projectId});
}

@LazySingleton(as: TasksDataSource)
class MockTasksDataSource implements TasksDataSource {
  final MockJsonDataSource _jsonDataSource;
  final MockNetwork _network;

  MockTasksDataSource(this._jsonDataSource, this._network);

  @override
  Future<List<TaskModel>> getTasksByProject({required String projectId}) async {
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
        .map(TaskModel.fromJson)
        .toList();
  }
}