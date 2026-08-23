import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:taskflow/core/utils/logger.dart';
import 'package:taskflow/features/projects/data/datasources/projects_datasource.dart';
import 'package:taskflow/features/projects/domain/entities/project.dart';
import 'package:taskflow/features/projects/domain/entities/project_task.dart';
import 'package:taskflow/features/projects/domain/repositories/projects_repository.dart';

import '../../../../core/error/failures.dart';

@LazySingleton(as: ProjectsRepository)
class ProjectsRepositoryImpl implements ProjectsRepository {
  final ProjectsDataSource _dataSource;

  final Map<String, List<Project>> _lastSuccessfulByOrg = {};
  final Map<String, Project> _lastSuccessfulProjectById = {};
  final Map<String, List<ProjectTask>> _lastSuccessfulTasksByProjectId = {};

  ProjectsRepositoryImpl(this._dataSource);

  @override
  Future<Either<Failure, List<Project>>> getProjects({required String orgId}) async {
    try {
      final models = await _dataSource.getProjects(orgId: orgId);
      final projects = models.map((model) => model.toEntity()).toList();
      _lastSuccessfulByOrg[orgId] = projects;
      return Right(projects);
    } on OfflineFailure {
      final cached = _lastSuccessfulByOrg[orgId];
      return Left(OfflineFailure(cached, cached == null || cached.isEmpty
          ? 'You are offline and no cached projects are available'
          : 'You are offline. Showing last synced projects.'));
    } on NotFoundFailure catch (failure) {
      return Left(failure);
    } on TimeoutFailure catch (failure) {
      return Left(failure);
    } on ValidationFailure catch (failure) {
      return Left(failure);
    } catch (error, stackTrace) {
      AppLogger.error('ProjectsRepositoryImpl.getProjects failed for orgId=$orgId', error: error, stackTrace: stackTrace);
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, Project>> getProjectById({required String projectId}) async {
    try {
      final model = await _dataSource.getProjectById(projectId: projectId);
      final project = model.toEntity();
      _lastSuccessfulProjectById[projectId] = project;
      return Right(project);
    } on OfflineFailure {
      final cached = _lastSuccessfulProjectById[projectId];
      if (cached == null) {
        return const Left(OfflineFailure(null, 'You are offline and no cached project is available'));
      }
      return Left(OfflineFailure(cached, 'You are offline. Showing last synced project.'));
    } on NotFoundFailure catch (failure) {
      return Left(failure);
    } on TimeoutFailure catch (failure) {
      return Left(failure);
    } on ValidationFailure catch (failure) {
      return Left(failure);
    } catch (error, stackTrace) {
      AppLogger.error('ProjectsRepositoryImpl.getProjectById failed for projectId=$projectId', error: error, stackTrace: stackTrace);
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, List<ProjectTask>>> getProjectTasks({required String projectId}) async {
    try {
      final models = await _dataSource.getProjectTasks(projectId: projectId);
      final tasks = models.map((model) => model.toEntity()).toList();
      _lastSuccessfulTasksByProjectId[projectId] = tasks;
      return Right(tasks);
    } on OfflineFailure {
      final cached = _lastSuccessfulTasksByProjectId[projectId];
      return Left(OfflineFailure(cached, cached == null || cached.isEmpty
          ? 'You are offline and no cached tasks are available'
          : 'You are offline. Showing last synced tasks.'));
    } on NotFoundFailure catch (failure) {
      return Left(failure);
    } on TimeoutFailure catch (failure) {
      return Left(failure);
    } on ValidationFailure catch (failure) {
      return Left(failure);
    } catch (error, stackTrace) {
      AppLogger.error('ProjectsRepositoryImpl.getProjectTasks failed for projectId=$projectId', error: error, stackTrace: stackTrace);
      return const Left(UnknownFailure());
    }
  }
}