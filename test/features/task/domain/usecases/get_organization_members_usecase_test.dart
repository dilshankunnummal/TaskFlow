import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:taskflow/core/error/failures.dart';
import 'package:taskflow/features/tasks/domain/entities/organization_member.dart';
import 'package:taskflow/features/tasks/domain/repositories/task_repository.dart';
import 'package:taskflow/features/tasks/domain/usecases/get_organization_members_usecase.dart';

class MockTaskRepository extends Mock implements TaskRepository {}

void main() {
  late MockTaskRepository repository;
  late GetOrganizationMembersUseCase useCase;

  const orgId = 'org_a1b2c3';
  const member = OrganizationMember(
    id: 'user_001',
    name: 'Ava Thompson',
    email: 'ava@test.com',
    role: 'org_admin',
  );

  setUp(() {
    repository = MockTaskRepository();
    useCase = GetOrganizationMembersUseCase(repository);
  });

  group('GetOrganizationMembersUseCase', () {
    test('returns ValidationFailure when organizationId is empty', () async {
      final result = await useCase('   ');

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<ValidationFailure>()),
        (_) => fail('Expected Left'),
      );
    });

    test('calls repository.getOrganizationMembers and returns members list',
        () async {
      when(() => repository.getOrganizationMembers(orgId))
          .thenAnswer((_) async => const Right([member]));

      final result = await useCase(orgId);

      expect(result, const Right([member]));
      verify(() => repository.getOrganizationMembers(orgId)).called(1);
    });
  });
}
