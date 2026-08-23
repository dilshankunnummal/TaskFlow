import 'package:injectable/injectable.dart';
import 'package:taskflow/core/data/mock_json_data_source.dart';
import 'package:taskflow/core/error/failures.dart';
import 'package:taskflow/core/network/mock_network.dart';
import 'package:taskflow/features/tasks/data/models/task_assignee_model.dart';
import 'package:taskflow/features/tasks/data/models/task_comment_model.dart';
import 'package:taskflow/features/tasks/data/models/task_details_model.dart';
import 'package:taskflow/features/tasks/data/models/task_model.dart';

abstract class TasksDataSource {
  Future<List<TaskModel>> getTasksByProject({required String projectId});

  Future<TaskDetailsModel> getTaskDetails({required String taskId});
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

  @override
  Future<TaskDetailsModel> getTaskDetails({required String taskId}) async {
    await _network.simulateDelay();

    if (!_network.isOnline) {
      throw const OfflineFailure(null);
    }

    if (taskId.trim().isEmpty) {
      throw const ValidationFailure('taskId must not be empty');
    }

    final taskRows = await _jsonDataSource.section('tasks');
    final taskRow = taskRows.firstWhere(
      (row) => row['id'] == taskId,
      orElse: () => const <String, dynamic>{},
    );

    if (taskRow.isEmpty) {
      throw const NotFoundFailure();
    }

    final taskModel = TaskModel.fromJson(taskRow);

    final userRows = await _jsonDataSource.section('users');
    final userMap = <String, Map<String, dynamic>>{
      for (final u in userRows) u['id'] as String: u,
    };

    final assigneeId = taskRow['assignee_id'] as String?;
    TaskAssigneeModel? assigneeModel;
    if (assigneeId != null && userMap.containsKey(assigneeId)) {
      assigneeModel = TaskAssigneeModel.fromJson(userMap[assigneeId]!);
    }

    final commentRows = await _jsonDataSource.section('comments');
    final comments =
        commentRows.where((row) => row['task_id'] == taskId).map((row) {
      final authorId = row['author_id'] as String;
      final authorName = userMap[authorId]?['name'] as String? ?? 'Unknown';
      return TaskCommentModel.fromJson(row, authorName: authorName);
    }).toList();

    return TaskDetailsModel(
      task: taskModel,
      assignee: assigneeModel,
      comments: comments,
    );
  }
}
