import 'package:dartz/dartz.dart' hide Task;
import 'package:injectable/injectable.dart';
import 'package:taskflow/core/error/failures.dart';
import 'package:taskflow/core/utils/logger.dart';
import 'package:taskflow/features/tasks/data/datasources/tasks_datasource.dart';
import 'package:taskflow/features/tasks/data/datasources/tasks_local_datasource.dart';
import 'package:taskflow/features/tasks/domain/entities/task.dart';
import 'package:taskflow/features/tasks/domain/repositories/task_repository.dart';

@LazySingleton(as: TaskRepository)
class TaskRepositoryImpl implements TaskRepository {
  final TasksDataSource _dataSource;
  final TasksLocalDataSource _localDataSource;

  final Map<String, List<Task>> _lastSuccessfulByProject = {};

  TaskRepositoryImpl(this._dataSource, this._localDataSource);

  @override
  Future<Either<Failure, List<Task>>> getTasksByProject({required String projectId}) async {
    try {
      final hasCache = await _localDataSource.hasCacheForProject(projectId);

      if (!hasCache) {
        return _seedAndReturn(projectId);
      }

      final cachedModels = await _localDataSource.getCachedTasksForProject(projectId);
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
  Future<Either<Failure, List<Task>>> refreshTasks({required String projectId}) async {
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
    final remoteModels = await _dataSource.getTasksByProject(projectId: projectId);
    final scopedModels = remoteModels.where((model) => model.projectId == projectId).toList();

    if (forceRefresh) {
      await _localDataSource.clearCacheForProject(projectId);
    }
    await _localDataSource.cacheTasksForProject(projectId, scopedModels);

    final tasks = scopedModels.map((model) => model.toEntity()).toList();
    _lastSuccessfulByProject[projectId] = tasks;
    return Right(tasks);
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
}