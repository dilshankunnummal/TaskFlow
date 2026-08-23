import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:taskflow/core/error/failures.dart';
import 'package:taskflow/core/error/result.dart';
import 'package:taskflow/features/auth/domain/entities/user_entity.dart';
import 'package:taskflow/features/home/domain/entities/activity_item_entity.dart';
import 'package:taskflow/features/home/domain/entities/dashboard_data.dart';
import 'package:taskflow/features/home/domain/entities/dashboard_summary.dart';
import 'package:taskflow/features/home/domain/usecases/get_dashboard_data_usecase.dart';
import 'package:taskflow/features/home/presentation/bloc/dashboard_bloc.dart';
import 'package:taskflow/features/home/presentation/bloc/dashboard_event.dart';
import 'package:taskflow/features/home/presentation/bloc/dashboard_state.dart';

class MockGetDashboardDataUseCase extends Mock implements GetDashboardDataUseCase {}

void main() {
  late MockGetDashboardDataUseCase useCase;

  const user = UserEntity(
    id: 'user_001',
    name: 'Ava Thompson',
    email: 'ava.admin@nimbusdigital.test',
    role: 'org_admin',
    orgId: 'org_a1b2c3',
  );

  final populatedData = DashboardData(
    user: user,
    organizationName: 'Nimbus Digital',
    summary: const DashboardSummary(totalProjects: 3, totalTasks: 15, tasksInProgress: 5, completedTasks: 6),
    recentActivity: [
      ActivityItemEntity(
        id: 'task_2001',
        title: 'Set up design tokens in Figma',
        projectName: 'Website Relaunch',
        status: 'done',
        timestamp: DateTime(2025, 12, 2),
      ),
    ],
  );

  final emptyData = DashboardData(
    user: user,
    organizationName: 'Nimbus Digital',
    summary: const DashboardSummary(totalProjects: 0, totalTasks: 0, tasksInProgress: 0, completedTasks: 0),
    recentActivity: const [],
  );

  setUp(() {
    useCase = MockGetDashboardDataUseCase();
  });

  DashboardBloc buildBloc() => DashboardBloc(useCase);

  group('DashboardBloc', () {
    test('initial state is DashboardInitial', () {
      expect(buildBloc().state, const DashboardInitial());
    });

    blocTest<DashboardBloc, DashboardState>(
      'emits [DashboardLoading, DashboardSuccess] when the org has projects and tasks',
      build: () {
        when(() => useCase()).thenAnswer((_) async => Success(populatedData));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const LoadDashboard()),
      expect: () => [const DashboardLoading(), DashboardSuccess(data: populatedData)],
    );

    blocTest<DashboardBloc, DashboardState>(
      'emits [DashboardLoading, DashboardEmpty] when the org has no projects or tasks',
      build: () {
        when(() => useCase()).thenAnswer((_) async => Success(emptyData));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const LoadDashboard()),
      expect: () => [const DashboardLoading(), DashboardEmpty(data: emptyData)],
    );

    blocTest<DashboardBloc, DashboardState>(
      'emits [DashboardLoading, DashboardError] when the use case fails',
      build: () {
        when(() => useCase()).thenAnswer((_) async => const ResultFailure(UnauthorizedFailure()));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const LoadDashboard()),
      expect: () => [
        const DashboardLoading(),
        const DashboardError('Your session has expired. Please sign in again.'),
      ],
    );

    blocTest<DashboardBloc, DashboardState>(
      'emits a refreshing success state before the refreshed data on RefreshDashboard',
      build: () {
        when(() => useCase()).thenAnswer((_) async => Success(populatedData));
        return buildBloc();
      },
      seed: () => DashboardSuccess(data: populatedData),
      act: (bloc) => bloc.add(const RefreshDashboard()),
      expect: () => [
        DashboardSuccess(data: populatedData, isRefreshing: true),
        DashboardSuccess(data: populatedData),
      ],
    );
  });
}
