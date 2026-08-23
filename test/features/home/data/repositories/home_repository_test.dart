import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:taskflow/core/error/failures.dart';
import 'package:taskflow/core/error/result.dart';
import 'package:taskflow/features/auth/domain/entities/user_entity.dart';
import 'package:taskflow/features/auth/domain/repositories/auth_repository.dart';
import 'package:taskflow/features/home/data/datasources/home_mock_datasource.dart';
import 'package:taskflow/features/home/data/models/activity_item_model.dart';
import 'package:taskflow/features/home/data/models/dashboard_summary_raw.dart';
import 'package:taskflow/features/home/data/repositories/home_repository_impl.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class MockHomeMockDataSource extends Mock implements HomeMockDataSource {}

void main() {
  late MockAuthRepository authRepository;
  late MockHomeMockDataSource dataSource;
  late HomeRepositoryImpl repository;

  const user = UserEntity(
    id: 'user_001',
    name: 'Ava Thompson',
    email: 'ava.admin@nimbusdigital.test',
    role: 'org_admin',
    orgId: 'org_a1b2c3',
  );

  setUp(() {
    authRepository = MockAuthRepository();
    dataSource = MockHomeMockDataSource();
    repository = HomeRepositoryImpl(authRepository, dataSource);
  });

  group('HomeRepositoryImpl.getDashboardData', () {
    test('returns dashboard data built from the current user and mock datasource', () async {
      when(() => authRepository.getCurrentUser()).thenAnswer((_) async => const Success(user));
      when(() => dataSource.getDashboardSummary(orgId: user.orgId)).thenAnswer(
        (_) async => DashboardSummaryRaw(
          organizationName: 'Nimbus Digital',
          totalProjects: 3,
          totalTasks: 15,
          tasksInProgress: 5,
          completedTasks: 6,
          recentActivity: [
            ActivityItemModel(
              id: 'task_2001',
              title: 'Set up design tokens in Figma',
              projectName: 'Website Relaunch',
              status: 'done',
              timestamp: DateTime(2025, 12, 2),
            ),
          ],
        ),
      );

      final result = await repository.getDashboardData();

      expect(result.isSuccess, isTrue);
      final data = result.valueOrNull!;
      expect(data.organizationName, 'Nimbus Digital');
      expect(data.summary.totalProjects, 3);
      expect(data.summary.tasksInProgress, 5);
      expect(data.recentActivity, hasLength(1));
      expect(data.recentActivity.first.title, 'Set up design tokens in Figma');
    });

    test('returns UnauthorizedFailure when there is no current user', () async {
      when(() => authRepository.getCurrentUser()).thenAnswer((_) async => const Success(null));

      final result = await repository.getDashboardData();

      expect(result.isFailure, isTrue);
      expect(result.failureOrNull, isA<UnauthorizedFailure>());
      verifyNever(() => dataSource.getDashboardSummary(orgId: any(named: 'orgId')));
    });

    test('propagates a failure from the auth repository', () async {
      when(() => authRepository.getCurrentUser()).thenAnswer(
        (_) async => const ResultFailure(CacheFailure('Unable to read the authentication session.')),
      );

      final result = await repository.getDashboardData();

      expect(result.isFailure, isTrue);
      expect(result.failureOrNull, isA<CacheFailure>());
    });
  });
}
