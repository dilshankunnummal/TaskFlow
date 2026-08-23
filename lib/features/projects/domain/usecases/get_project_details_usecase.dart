import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:taskflow/core/error/failures.dart';
import 'package:taskflow/features/projects/domain/entities/project.dart';
import 'package:taskflow/features/projects/domain/entities/project_details.dart';
import 'package:taskflow/features/projects/domain/entities/project_task.dart';
import 'package:taskflow/features/projects/domain/repositories/projects_repository.dart';

@injectable
class GetProjectDetailsUseCase {
  final ProjectsRepository repository;

  GetProjectDetailsUseCase(this.repository);

  Future<Either<Failure, ProjectDetails>> call({required String projectId}) async {
    final projectResult = await repository.getProjectById(projectId: projectId);

    Failure? projectFailure;
    Project? project;
    projectResult.fold(
      (failure) => projectFailure = failure,
      (value) => project = value,
    );

    if (projectFailure != null) {
      return Left(projectFailure!);
    }

    final tasksResult = await repository.getProjectTasks(projectId: projectId);

    Failure? tasksFailure;
    List<ProjectTask>? tasks;
    tasksResult.fold(
      (failure) => tasksFailure = failure,
      (value) => tasks = value,
    );

    if (tasksFailure != null) {
      return Left(tasksFailure!);
    }

    return Right(ProjectDetails(project: project!, tasks: tasks!));
  }
}
