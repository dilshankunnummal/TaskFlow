import 'package:dartz/dartz.dart';
import 'package:taskflow/core/error/failures.dart';
import 'package:taskflow/features/projects/domain/entities/project.dart';
import 'package:taskflow/features/projects/domain/entities/project_task.dart';

abstract class ProjectsRepository {
  Future<Either<Failure, List<Project>>> getProjects({required String orgId});

  Future<Either<Failure, Project>> getProjectById({required String projectId});

  Future<Either<Failure, List<ProjectTask>>> getProjectTasks({required String projectId});

  Future<Either<Failure, Project>> createProject({required Project project});

  Future<Either<Failure, Project>> updateProject({required Project project});

  Future<Either<Failure, Unit>> deleteProject({required String projectId});
}