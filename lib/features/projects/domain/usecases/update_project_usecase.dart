import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:taskflow/core/auth/current_session.dart';
import 'package:taskflow/core/error/failures.dart';
import 'package:taskflow/features/projects/domain/entities/project.dart';
import 'package:taskflow/features/projects/domain/repositories/projects_repository.dart';

@injectable
class UpdateProjectUseCase {
  UpdateProjectUseCase(this._repository, this._session);

  final ProjectsRepository _repository;
  final CurrentSession _session;

  Future<Either<Failure, Project>> call({required Project project}) async {
    final role = await _session.currentUserRole;
    if (role != 'org_admin') {
      return const Left(UnauthorizedFailure('Only organization admins can edit projects.'));
    }

    final validationFailure = _validate(project);
    if (validationFailure != null) {
      return Left(validationFailure);
    }

    final sanitized = project.copyWith(
      name: project.name.trim(),
      description: project.description.trim(),
    );

    return _repository.updateProject(project: sanitized);
  }

  ValidationFailure? _validate(Project project) {
    if (project.id.trim().isEmpty) {
      return const ValidationFailure('id must not be empty');
    }
    if (project.orgId.trim().isEmpty) {
      return const ValidationFailure('orgId must not be empty');
    }
    if (project.name.trim().isEmpty) {
      return const ValidationFailure('Project name must not be empty');
    }
    if (project.name.trim().length > 120) {
      return const ValidationFailure('Project name must be 120 characters or fewer');
    }
    if (project.description.trim().isEmpty) {
      return const ValidationFailure('Project description must not be empty');
    }
    return null;
  }
}