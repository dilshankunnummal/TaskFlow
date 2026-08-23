import 'package:dartz/dartz.dart';
import 'package:taskflow/core/error/failures.dart';
import 'package:taskflow/features/projects/domain/entities/project.dart';

abstract class ProjectsRepository {
  Future<Either<Failure, List<Project>>> getProjects({required String orgId});
}