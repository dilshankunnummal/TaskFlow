import 'package:dartz/dartz.dart' hide Task;
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:taskflow/core/error/failures.dart';
import 'package:taskflow/core/utils/logger.dart';
import 'package:taskflow/features/tasks/data/datasources/tasks_datasource.dart';
import 'package:taskflow/features/tasks/data/datasources/tasks_local_datasource.dart';
import 'package:taskflow/features/tasks/data/models/task_model.dart';
import 'package:taskflow/features/tasks/domain/entities/task.dart';
import 'package:taskflow/features/tasks/domain/entities/task_details.dart';
import 'package:taskflow/features/tasks/domain/entities/task_assignee.dart';
import 'package:taskflow/features/tasks/domain/repositories/task_repository.dart';

@LazySingleton(as: TaskRepository)
class TaskRepositoryImpl implements TaskRepository {
  final TasksDataSource _dataSource;
  final TasksLocalDataSource _localDataSource;

  final Map<String, List<Task>> _lastSuccessfulByProject = {};

  TaskRepositoryImpl(this._dataSource, this._localDataSource);

  @override
  Future<Either<Failure, List<Task>>> getTasksByProject(
      {required String projectId}) async {
    try {
      final hasCache = await _localDataSource.hasCacheForProject(projectId);

      if (!hasCache) {
        return _seedAndReturn(projectId);
      }

      final cachedModels =
      await _localDataSource.getCachedTasksForProject(projectId);
      final tasks = cachedModels
          .where((model) => model.projectId == projectId)
          .map((model) => model.toEntity())
          .toList();

      _lastSuccessfulByProject[projectId] = tasks;
      return Right(tasks);
    } on OfflineFailure {
      return _offlineFailureFor(projectId);
    } on NotFoundFailure catch (failure) {
      return Left(failure);
    } on TimeoutFailure catch (failure) {
      return Left(failure);
    } on ValidationFailure catch (failure) {
      return Left(failure);
    } catch (error, stackTrace) {
      AppLogger.error(
        'TaskRepositoryImpl.getTasksByProject failed for projectId=$projectId',
        error: error,
        stackTrace: stackTrace,
      );
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, List<Task>>> refreshTasks(
      {required String projectId}) async {
    try {
      return await _seedAndReturn(projectId, forceRefresh: true);
    } on OfflineFailure {
      return _offlineFailureFor(projectId);
    } on NotFoundFailure catch (failure) {
      return Left(failure);
    } on TimeoutFailure catch (failure) {
      return Left(failure);
    } on ValidationFailure catch (failure) {
      return Left(failure);
    } catch (error, stackTrace) {
      AppLogger.error(
        'TaskRepositoryImpl.refreshTasks failed for projectId=$projectId',
        error: error,
        stackTrace: stackTrace,
      );
      return const Left(UnknownFailure());
    }
  }

  Future<Either<Failure, List<Task>>> _seedAndReturn(
      String projectId, {
        bool forceRefresh = false,
      }) async {
    final remoteModels =
    await _dataSource.getTasksByProject(projectId: projectId);
    final scopedModels =
    remoteModels.where((model) => model.projectId == projectId).toList();

    var mergedModels = scopedModels;

    if (forceRefresh) {
      final locallyCreatedModels =
      await _findLocallyCreatedModels(projectId, scopedModels);
      await _localDataSource.clearCacheForProject(projectId);
      mergedModels = [...scopedModels, ...locallyCreatedModels];
    }

    await _localDataSource.cacheTasksForProject(projectId, mergedModels);

    final tasks = mergedModels.map((model) => model.toEntity()).toList();
    _lastSuccessfulByProject[projectId] = tasks;
    return Right(tasks);
  }

  Future<List<TaskModel>> _findLocallyCreatedModels(
      String projectId,
      List<TaskModel> remoteModels,
      ) async {
    final existingCached =
    await _localDataSource.getCachedTasksForProject(projectId);
    final remoteIds = remoteModels.map((model) => model.id).toSet();
    return existingCached
        .where((cached) => !remoteIds.contains(cached.id))
        .toList();
  }

  Either<Failure, List<Task>> _offlineFailureFor(String projectId) {
    final cached = _lastSuccessfulByProject[projectId];
    return Left(
      OfflineFailure(
        cached,
        cached == null || cached.isEmpty
            ? 'You are offline and no cached tasks are available'
            : 'You are offline. Showing last synced tasks.',
      ),
    );
  }

  @override
  Future<Either<Failure, TaskDetails>> getTaskDetails(
      {required String taskId}) async {
    try {
      AppLogger.error(
          'TaskRepositoryImpl.getTaskDetails looking up remote taskId=$taskId');
      final detailsModel = await _dataSource.getTaskDetails(taskId: taskId);
      await _localDataSource.upsertTask(detailsModel.task);
      return Right(detailsModel.toEntity());
    } on OfflineFailure {
      final cached = await _localDataSource.getCachedTask(taskId);
      if (cached != null) {
        TaskAssignee? assignee;
        if (cached.assigneeId != null) {
          final assigneesResult = await getAssignees();
          assigneesResult.fold(
                (_) {},
                (assignees) {
              for (final a in assignees) {
                if (a.id == cached.assigneeId) {
                  assignee = a;
                  break;
                }
              }
            },
          );
        }
        final staleDetails = TaskDetails(
          task: cached.toEntity(),
          assignee: assignee,
          comments: const [],
        );
        return Left(
          OfflineFailure(
            staleDetails,
            'You are offline. Showing cached task details.',
          ),
        );
      }
      return const Left(
        OfflineFailure(
            null, 'You are offline and no cached task is available.'),
      );
    } on NotFoundFailure catch (failure) {
      AppLogger.error(
          'TaskRepositoryImpl.getTaskDetails remote miss for taskId=$taskId, checking Hive cache');
      final cached = await _localDataSource.getCachedTask(taskId);
      if (cached != null) {
        AppLogger.error(
            'TaskRepositoryImpl.getTaskDetails found taskId=$taskId in Hive cache, using it');
        TaskAssignee? assignee;
        if (cached.assigneeId != null) {
          final assigneesResult = await getAssignees();
          assigneesResult.fold(
                (_) {},
                (assignees) {
              for (final a in assignees) {
                if (a.id == cached.assigneeId) {
                  assignee = a;
                  break;
                }
              }
            },
          );
        }
        return Right(TaskDetails(
          task: cached.toEntity(),
          assignee: assignee,
          comments: const [],
        ));
      }
      AppLogger.error(
          'TaskRepositoryImpl.getTaskDetails taskId=$taskId not found in Hive cache either, returning NotFoundFailure');
      return Left(failure);
    } on TimeoutFailure catch (failure) {
      return Left(failure);
    } on ValidationFailure catch (failure) {
      return Left(failure);
    } catch (error, stackTrace) {
      AppLogger.error(
        'TaskRepositoryImpl.getTaskDetails failed for taskId=$taskId',
        error: error,
        stackTrace: stackTrace,
      );
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, Task>> createTask(Task task) async {
    try {
      await _localDataSource.upsertTask(TaskModel.fromEntity(task));
      final projectId = task.projectId;
      final cachedList = _lastSuccessfulByProject[projectId];
      if (cachedList != null) {
        _lastSuccessfulByProject[projectId] = [...cachedList, task];
      }
      return Right(task);
    } catch (error, stackTrace) {
      AppLogger.error(
        'TaskRepositoryImpl.createTask failed for taskId=${task.id}',
        error: error,
        stackTrace: stackTrace,
      );
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, Task>> updateTask(Task task) async {
    try {
      await _localDataSource.upsertTask(TaskModel.fromEntity(task));
      final projectId = task.projectId;
      final cachedList = _lastSuccessfulByProject[projectId];
      if (cachedList != null) {
        final index = cachedList.indexWhere((t) => t.id == task.id);
        if (index != -1) {
          final updatedList = List<Task>.from(cachedList);
          updatedList[index] = task;
          _lastSuccessfulByProject[projectId] = updatedList;
        } else {
          _lastSuccessfulByProject[projectId] = [...cachedList, task];
        }
      }
      return Right(task);
    } catch (error, stackTrace) {
      AppLogger.error(
        'TaskRepositoryImpl.updateTask failed for taskId=${task.id}',
        error: error,
        stackTrace: stackTrace,
      );
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteTask(String taskId) async {
    try {
      await _localDataSource.deleteTask(taskId);
      for (final projectId in _lastSuccessfulByProject.keys) {
        final cachedList = _lastSuccessfulByProject[projectId];
        if (cachedList != null) {
          _lastSuccessfulByProject[projectId] =
              cachedList.where((t) => t.id != taskId).toList();
        }
      }
      return const Right(unit);
    } catch (error, stackTrace) {
      AppLogger.error(
        'TaskRepositoryImpl.deleteTask failed for taskId=$taskId',
        error: error,
        stackTrace: stackTrace,
      );
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, List<TaskAssignee>>> getAssignees() async {
    try {
      final models = await _dataSource.getAssignees();
      return Right(models.map((model) => model.toEntity()).toList());
    } on OfflineFailure {
      return const Left(OfflineFailure(null, 'You are offline. Cannot fetch assignees.'));
    } catch (error, stackTrace) {
      AppLogger.error(
        'TaskRepositoryImpl.getAssignees failed',
        error: error,
        stackTrace: stackTrace,
      );
      return const Left(UnknownFailure());
    }
  }
}