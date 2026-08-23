import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:taskflow/core/error/failures.dart';
import 'package:taskflow/features/projects/domain/entities/project.dart';
import 'package:taskflow/features/projects/domain/repositories/projects_repository.dart';

@injectable
class GetProjects {
  final ProjectsRepository repository;

  GetProjects(this.repository);

  Future<Either<Failure, List<Project>>> call({required String orgId}) {
    return repository.getProjects(orgId: orgId);
  }
}