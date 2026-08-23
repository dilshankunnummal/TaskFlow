import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:taskflow/core/error/failures.dart';
import 'package:taskflow/core/error/result.dart';
import 'package:taskflow/core/theme/app_theme.dart';
import 'package:taskflow/core/widgets/loading/app_skeleton_loader.dart';
import 'package:taskflow/features/auth/domain/entities/user_entity.dart';
import 'package:taskflow/features/home/domain/entities/dashboard_data.dart';
import 'package:taskflow/features/home/domain/entities/dashboard_summary.dart';
import 'package:taskflow/features/home/domain/usecases/get_dashboard_data_usecase.dart';
import 'package:taskflow/features/home/presentation/bloc/dashboard_bloc.dart';
import 'package:taskflow/features/home/presentation/pages/dashboard_page.dart';

class MockGetDashboardDataUseCase extends Mock implements GetDashboardDataUseCase {}

void main() {
  final getIt = GetIt.instance;
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
    recentActivity: const [],
  );

  final emptyData = DashboardData(
    user: user,
    organizationName: 'Nimbus Digital',
    summary: const DashboardSummary(totalProjects: 0, totalTasks: 0, tasksInProgress: 0, completedTasks: 0),
    recentActivity: const [],
  );

  setUp(() {
    useCase = MockGetDashboardDataUseCase();
    getIt
      ..reset()
      ..registerFactory<GetDashboardDataUseCase>(() => useCase)
      ..registerFactory<DashboardBloc>(() => DashboardBloc(getIt<GetDashboardDataUseCase>()));
  });

  tearDown(() async {
    await getIt.reset();
  });

  GoRouter buildRouter() {
    return GoRouter(
      initialLocation: '/dashboard',
      routes: [
        GoRoute(path: '/dashboard', builder: (context, state) => const DashboardPage()),
        GoRoute(path: '/projects', builder: (context, state) => const Scaffold(body: Text('Projects Screen'))),
        GoRoute(path: '/tasks', builder: (context, state) => const Scaffold(body: Text('Tasks Screen'))),
        GoRoute(path: '/profile', builder: (context, state) => const Scaffold(body: Text('Profile Screen'))),
      ],
    );
  }

  testWidgets('shows a loading skeleton while the dashboard data is being fetched', (tester) async {
    final completer = Completer<Result<DashboardData>>();
    when(() => useCase()).thenAnswer((_) => completer.future);

    await tester.pumpWidget(MaterialApp.router(theme: AppTheme.dark(), routerConfig: buildRouter()));
    await tester.pump();

    expect(find.byType(AppSkeletonLoader), findsOneWidget);
    expect(find.text('Nimbus Digital'), findsNothing);

    completer.complete(Success(populatedData));
    await tester.pumpAndSettle();
  });

  testWidgets('renders the header, summary and quick actions on success', (tester) async {
    when(() => useCase()).thenAnswer((_) async => Success(populatedData));

    await tester.pumpWidget(MaterialApp.router(theme: AppTheme.dark(), routerConfig: buildRouter()));
    await tester.pumpAndSettle();

    expect(find.text('Nimbus Digital'), findsOneWidget);
    expect(find.text('Total Projects'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
    expect(find.text('15'), findsOneWidget);
    expect(find.text('Org Admin'), findsOneWidget);
  });

  testWidgets('renders the empty state when the organization has no data', (tester) async {
    when(() => useCase()).thenAnswer((_) async => Success(emptyData));

    await tester.pumpWidget(MaterialApp.router(theme: AppTheme.dark(), routerConfig: buildRouter()));
    await tester.pumpAndSettle();

    expect(find.text('No recent activity'), findsOneWidget);
    expect(find.text('Total Projects'), findsNothing);
  });

  testWidgets('renders an error state with a retry action', (tester) async {
    when(() => useCase()).thenAnswer((_) async => const ResultFailure(ServerFailure('Unable to load dashboard.')));

    await tester.pumpWidget(MaterialApp.router(theme: AppTheme.dark(), routerConfig: buildRouter()));
    await tester.pumpAndSettle();

    expect(find.text('Unable to load dashboard.'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
  });

  testWidgets('navigates to the projects route when the quick action is tapped', (tester) async {
    when(() => useCase()).thenAnswer((_) async => Success(populatedData));

    await tester.pumpWidget(MaterialApp.router(theme: AppTheme.dark(), routerConfig: buildRouter()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Projects'));
    await tester.pumpAndSettle();

    expect(find.text('Projects Screen'), findsOneWidget);
  });
}
