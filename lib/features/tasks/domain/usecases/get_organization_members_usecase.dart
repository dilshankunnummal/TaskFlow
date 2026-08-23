import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:taskflow/core/error/failures.dart';
import 'package:taskflow/features/tasks/domain/entities/organization_member.dart';
import 'package:taskflow/features/tasks/domain/repositories/task_repository.dart';

@injectable
class GetOrganizationMembersUseCase {
  final TaskRepository _repository;

  GetOrganizationMembersUseCase(this._repository);

  Future<Either<Failure, List<OrganizationMember>>> call(
      String organizationId) async {
    if (organizationId.trim().isEmpty) {
      return const Left(
          ValidationFailure('organizationId must not be empty'));
    }
    return _repository.getOrganizationMembers(organizationId);
  }
}
