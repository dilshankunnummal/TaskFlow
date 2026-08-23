import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:taskflow/core/utils/logger.dart';
import 'package:taskflow/features/projects/data/datasources/projects_datasource.dart';
import 'package:taskflow/features/projects/data/datasources/projects_local_datasource.dart';
import 'package:taskflow/features/projects/data/models/project_model.dart';
import 'package:taskflow/features/projects/data/models/project_task_model.dart';
import 'package:taskflow/features/projects/domain/entities/project.dart';
import 'package:taskflow/features/projects/domain/entities/project_task.dart';
import 'package:taskflow/features/projects/domain/repositories/projects_repository.dart';

import 'package:taskflow/features/tasks/data/datasources/tasks_local_datasource.dart';
import 'package:taskflow/features/tasks/data/models/task_model.dart';

import '../../../../core/error/failures.dart';

@LazySingleton(as: ProjectsRepository)
class ProjectsRepositoryImpl implements ProjectsRepository {
  final ProjectsDataSource _dataSource;
  final ProjectsLocalDataSource _localDataSource;
  final TasksLocalDataSource _tasksLocalDataSource;

  final Map<String, List<Project>> _lastSuccessfulByOrg = {};
  final Map<String, Project> _lastSuccessfulProjectById = {};
  final Map<String, List<ProjectTask>> _lastSuccessfulTasksByProjectId = {};

  ProjectsRepositoryImpl(
    this._dataSource,
    this._localDataSource,
    this._tasksLocalDataSource,
  );

  @override
  Future<Either<Failure, List<Project>>> getProjects(
      {required String orgId}) async {
    try {
      final remoteModels = await _dataSource.getProjects(orgId: orgId);
      for (final model in remoteModels) {
        await _localDataSource.saveProject(model);
      }
      final localModels = await _localDataSource.getProjectsForOrg(orgId);
      final deletedIds = await _localDataSource.getDeletedProjectIds();
      final activeRemote = remoteModels
          .where((model) => !deletedIds.contains(model.id))
          .toList();
      final mergedModels = _mergeProjectModels(activeRemote, localModels);
      final projects = mergedModels.map((model) => model.toEntity()).toList();
      _lastSuccessfulByOrg[orgId] = projects;
      return Right(projects);
    } on OfflineFailure {
      final localModels = await _localDataSource.getProjectsForOrg(orgId);
      final deletedIds = await _localDataSource.getDeletedProjectIds();
      final localProjects = localModels
          .where((model) => !deletedIds.contains(model.id))
          .map((model) => model.toEntity())
          .toList();

      final cached = _lastSuccessfulByOrg[orgId] ??
          (localProjects.isNotEmpty ? localProjects : null);

      if (cached != null && cached.isNotEmpty) {
        return Left(OfflineFailure(
            cached, 'You are offline. Showing last synced projects.'));
      }
      return const Left(OfflineFailure(
          null, 'You are offline and no cached projects are available'));
    } on NotFoundFailure catch (failure) {
      return Left(failure);
    } on TimeoutFailure catch (failure) {
      return Left(failure);
    } on ValidationFailure catch (failure) {
      return Left(failure);
    } catch (error, stackTrace) {
      AppLogger.error(
          'ProjectsRepositoryImpl.getProjects failed for orgId=$orgId',
          error: error,
          stackTrace: stackTrace);
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, Project>> getProjectById(
      {required String projectId}) async {
    try {
      final deletedIds = await _localDataSource.getDeletedProjectIds();
      if (deletedIds.contains(projectId)) {
        return const Left(NotFoundFailure());
      }

      ProjectModel? remoteModel;
      try {
        remoteModel = await _dataSource.getProjectById(projectId: projectId);
        if (remoteModel != null) {
          await _localDataSource.saveProject(remoteModel);
        }
      } on NotFoundFailure {
        remoteModel = null;
      }

      final localModel = await _localDataSource.getProject(projectId);
      final resolvedModel = remoteModel ?? localModel;

      if (resolvedModel == null) {
        return const Left(NotFoundFailure());
      }

      final project = resolvedModel.toEntity();
      _lastSuccessfulProjectById[projectId] = project;
      return Right(project);
    } on OfflineFailure {
      final localModel = await _localDataSource.getProject(projectId);
      final cached =
          _lastSuccessfulProjectById[projectId] ?? localModel?.toEntity();
      if (cached == null) {
        return const Left(OfflineFailure(
            null, 'You are offline and no cached project is available'));
      }
      return Left(OfflineFailure(
          cached, 'You are offline. Showing last synced project.'));
    } on NotFoundFailure catch (failure) {
      return Left(failure);
    } on TimeoutFailure catch (failure) {
      return Left(failure);
    } on ValidationFailure catch (failure) {
      return Left(failure);
    } catch (error, stackTrace) {
      AppLogger.error(
          'ProjectsRepositoryImpl.getProjectById failed for projectId=$projectId',
          error: error,
          stackTrace: stackTrace);
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, List<ProjectTask>>> getProjectTasks(
      {required String projectId}) async {
    try {
      List<ProjectTaskModel> remoteModels = [];
      try {
        remoteModels = await _dataSource.getProjectTasks(projectId: projectId);
      } catch (_) {}

      final localTasks = await _tasksLocalDataSource.getCachedTasksForProject(projectId);
      final mergedModels = _mergeProjectTaskModels(remoteModels, localTasks);
      final tasks = mergedModels.map((model) => model.toEntity()).toList();
      _lastSuccessfulTasksByProjectId[projectId] = tasks;
      return Right(tasks);
    } on OfflineFailure {
      final localTasks = await _tasksLocalDataSource.getCachedTasksForProject(projectId);
      final tasks = localTasks
          .map((t) => ProjectTaskModel(
                id: t.id,
                projectId: t.projectId,
                title: t.title,
                description: t.description,
                status: t.status,
                priority: t.priority,
                assigneeId: t.assigneeId,
                dueDate: t.dueDate,
                createdAt: t.createdAt,
              ).toEntity())
          .toList();

      final cached = _lastSuccessfulTasksByProjectId[projectId] ??
          (tasks.isNotEmpty ? tasks : null);
      if (cached != null && cached.isNotEmpty) {
        return Left(OfflineFailure(cached, 'You are offline. Showing cached tasks.'));
      }
      return const Left(
          OfflineFailure(null, 'You are offline and no cached tasks are available'));
    } catch (error, stackTrace) {
      AppLogger.error(
          'ProjectsRepositoryImpl.getProjectTasks failed for projectId=$projectId',
          error: error,
          stackTrace: stackTrace);
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, Project>> createProject(
      {required Project project}) async {
    try {
      await _localDataSource.saveProject(ProjectModel.fromEntity(project));

      _lastSuccessfulProjectById[project.id] = project;
      final cachedList = _lastSuccessfulByOrg[project.orgId];
      if (cachedList != null) {
        _lastSuccessfulByOrg[project.orgId] = [...cachedList, project];
      }

      return Right(project);
    } catch (error, stackTrace) {
      AppLogger.error(
          'ProjectsRepositoryImpl.createProject failed for projectId=${project.id}',
          error: error,
          stackTrace: stackTrace);
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, Project>> updateProject(
      {required Project project}) async {
    try {
      await _localDataSource.saveProject(ProjectModel.fromEntity(project));

      _lastSuccessfulProjectById[project.id] = project;
      final cachedList = _lastSuccessfulByOrg[project.orgId];
      if (cachedList != null) {
        _lastSuccessfulByOrg[project.orgId] = [
          for (final existing in cachedList)
            if (existing.id == project.id) project else existing,
        ];
      }

      return Right(project);
    } catch (error, stackTrace) {
      AppLogger.error(
          'ProjectsRepositoryImpl.updateProject failed for projectId=${project.id}',
          error: error,
          stackTrace: stackTrace);
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteProject(
      {required String projectId}) async {
    try {
      await _localDataSource.deleteProject(projectId);

      _lastSuccessfulProjectById.remove(projectId);
      _lastSuccessfulTasksByProjectId.remove(projectId);
      _lastSuccessfulByOrg.updateAll(
        (orgId, projects) =>
            projects.where((project) => project.id != projectId).toList(),
      );

      return const Right(unit);
    } on NotFoundFailure catch (failure) {
      return Left(failure);
    } on ValidationFailure catch (failure) {
      return Left(failure);
    } catch (error, stackTrace) {
      AppLogger.error(
          'ProjectsRepositoryImpl.deleteProject failed for projectId=$projectId',
          error: error,
          stackTrace: stackTrace);
      return const Left(UnknownFailure());
    }
  }

  List<ProjectModel> _mergeProjectModels(
      List<ProjectModel> remote, List<ProjectModel> local) {
    final byId = {for (final model in local) model.id: model};
    for (final model in remote) {
      byId[model.id] = model;
    }
    return byId.values.toList();
  }

  List<ProjectTaskModel> _mergeProjectTaskModels(
      List<ProjectTaskModel> remote, List<TaskModel> localTasks) {
    final byId = {for (final model in remote) model.id: model};
    for (final task in localTasks) {
      byId[task.id] = ProjectTaskModel(
        id: task.id,
        projectId: task.projectId,
        title: task.title,
        description: task.description,
        status: task.status,
        priority: task.priority,
        assigneeId: task.assigneeId,
        dueDate: task.dueDate,
        createdAt: task.createdAt,
      );
    }
    return byId.values.toList();
  }
}
