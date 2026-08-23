import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:taskflow/core/auth/current_session.dart';
import 'package:taskflow/core/error/failures.dart';
import 'package:taskflow/features/tasks/domain/entities/organization_member.dart';
import 'package:taskflow/features/tasks/domain/repositories/task_repository.dart';

@injectable
class GetOrganizationMembersUseCase {
  final TaskRepository _repository;
  final CurrentSession _session;

  GetOrganizationMembersUseCase(this._repository, this._session);

  Future<Either<Failure, List<OrganizationMember>>> call(
      String organizationId) async {
    if (organizationId.trim().isEmpty) {
      return const Left(
          ValidationFailure('organizationId must not be empty'));
    }

    final role = await _session.currentUserRole;
    if (role != 'org_admin') {
      return const Left(
          UnauthorizedFailure('You don\'t have access to manage members.'));
    }

    return _repository.getOrganizationMembers(organizationId);
  }
}
