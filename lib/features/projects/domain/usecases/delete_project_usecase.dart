import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:taskflow/core/auth/current_session.dart';
import 'package:taskflow/core/error/failures.dart';
import 'package:taskflow/features/projects/domain/repositories/projects_repository.dart';

const String _orgAdminRole = 'org_admin';

@injectable
class DeleteProjectUseCase {
  DeleteProjectUseCase(this._repository, this._session);

  final ProjectsRepository _repository;
  final CurrentSession _session;

  Future<Either<Failure, Unit>> call({required String projectId}) async {
    if (projectId.trim().isEmpty) {
      return const Left(ValidationFailure('projectId must not be empty'));
    }

    final role = await _session.currentUserRole;
    if (role != _orgAdminRole) {
      return const Left(PermissionFailure());
    }

    return _repository.deleteProject(projectId: projectId);
  }
}