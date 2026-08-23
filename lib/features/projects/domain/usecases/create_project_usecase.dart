import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:taskflow/core/auth/current_session.dart';
import 'package:taskflow/core/error/failures.dart';
import 'package:taskflow/core/utils/id_generator.dart';
import 'package:taskflow/features/projects/domain/entities/project.dart';
import 'package:taskflow/features/projects/domain/repositories/projects_repository.dart';

@injectable
class CreateProjectUseCase {
  CreateProjectUseCase(this._repository, this._idGenerator, this._session);

  final ProjectsRepository _repository;
  final IdGenerator _idGenerator;
  final CurrentSession _session;

  Future<Either<Failure, Project>> call({
    required String orgId,
    required String name,
    required String description,
    ProjectStatus status = ProjectStatus.planning,
  }) async {
    final role = await _session.currentUserRole;
    if (role != 'org_admin') {
      return const Left(UnauthorizedFailure('Only organization admins can create projects.'));
    }

    final validationFailure = _validate(
      orgId: orgId,
      name: name,
      description: description,
    );
    if (validationFailure != null) {
      return Left(validationFailure);
    }

    final project = Project(
      id: _idGenerator.generate(),
      orgId: orgId.trim(),
      name: name.trim(),
      description: description.trim(),
      status: status,
      taskCount: 0,
      createdAt: DateTime.now(),
    );

    return _repository.createProject(project: project);
  }

  ValidationFailure? _validate({
    required String orgId,
    required String name,
    required String description,
  }) {
    if (orgId.trim().isEmpty) {
      return const ValidationFailure('orgId must not be empty');
    }
    if (name.trim().isEmpty) {
      return const ValidationFailure('Project name must not be empty');
    }
    if (name.trim().length > 120) {
      return const ValidationFailure('Project name must be 120 characters or fewer');
    }
    if (description.trim().isEmpty) {
      return const ValidationFailure('Project description must not be empty');
    }
    return null;
  }
}