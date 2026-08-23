import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:taskflow/core/utils/logger.dart';
import 'package:taskflow/features/projects/data/datasources/projects_datasource.dart';
import 'package:taskflow/features/projects/domain/entities/project.dart';
import 'package:taskflow/features/projects/domain/repositories/projects_repository.dart';

import '../../../../core/error/failures.dart';

@LazySingleton(as: ProjectsRepository)
class ProjectsRepositoryImpl implements ProjectsRepository {
  final ProjectsDataSource _dataSource;

  final Map<String, List<Project>> _lastSuccessfulByOrg = {};

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
}