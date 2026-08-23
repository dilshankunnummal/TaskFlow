import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:taskflow/core/constants/app_strings.dart';
import 'package:taskflow/core/error/failures.dart';
import 'package:taskflow/core/error/result.dart';
import 'package:taskflow/core/theme/app_theme.dart';
import 'package:taskflow/core/widgets/loading/app_loading_indicator.dart';
import 'package:taskflow/features/auth/domain/entities/session_status.dart';
import 'package:taskflow/features/auth/domain/usecases/check_session_usecase.dart';
import 'package:taskflow/features/auth/domain/usecases/refresh_token_usecase.dart';
import 'package:taskflow/features/auth/presentation/bloc/splash_bloc.dart';
import 'package:taskflow/features/auth/presentation/pages/splash_page.dart';

class MockCheckSessionUseCase extends Mock implements CheckSessionUseCase {}

class MockRefreshTokenUseCase extends Mock implements RefreshTokenUseCase {}

void main() {
  final getIt = GetIt.instance;
  late MockCheckSessionUseCase checkSessionUseCase;
  late MockRefreshTokenUseCase refreshTokenUseCase;

  setUp(() {
    checkSessionUseCase = MockCheckSessionUseCase();
    refreshTokenUseCase = MockRefreshTokenUseCase();
    getIt
      ..reset()
      ..registerFactory<CheckSessionUseCase>(() => checkSessionUseCase)
      ..registerFactory<RefreshTokenUseCase>(() => refreshTokenUseCase)
      ..registerFactory<SplashBloc>(() => SplashBloc(getIt<CheckSessionUseCase>(), getIt<RefreshTokenUseCase>()));
  });

  tearDown(() async {
    await getIt.reset();
  });

  GoRouter buildRouter() {
    return GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(path: '/', builder: (context, state) => const SplashPage()),
        GoRoute(path: '/login', builder: (context, state) => const Scaffold(body: Text('Login Screen'))),
        GoRoute(path: '/dashboard', builder: (context, state) => const Scaffold(body: Text('Dashboard Screen'))),
      ],
    );
  }

  testWidgets('renders the app name and a loading indicator while checking the session', (tester) async {
    final completer = Completer<Result<SessionStatus>>();
    when(() => checkSessionUseCase()).thenAnswer((_) => completer.future);

    await tester.pumpWidget(MaterialApp.router(theme: AppTheme.dark(), routerConfig: buildRouter()));
    await tester.pump();

    expect(find.text(AppStrings.appName), findsOneWidget);
    expect(find.byType(AppLoadingIndicator), findsOneWidget);

    completer.complete(const Success(SessionStatus.none));
    await tester.pumpAndSettle();
  });

  testWidgets('navigates to dashboard when the session is valid', (tester) async {
    when(() => checkSessionUseCase()).thenAnswer((_) async => const Success(SessionStatus.valid));

    await tester.pumpWidget(MaterialApp.router(theme: AppTheme.dark(), routerConfig: buildRouter()));
    await tester.pumpAndSettle();

    expect(find.text('Dashboard Screen'), findsOneWidget);
  });

  testWidgets('navigates to login when there is no session', (tester) async {
    when(() => checkSessionUseCase()).thenAnswer((_) async => const Success(SessionStatus.none));

    await tester.pumpWidget(MaterialApp.router(theme: AppTheme.dark(), routerConfig: buildRouter()));
    await tester.pumpAndSettle();

    expect(find.text('Login Screen'), findsOneWidget);
  });

  testWidgets('navigates to login when an expired session fails to refresh', (tester) async {
    when(() => checkSessionUseCase()).thenAnswer((_) async => const Success(SessionStatus.expired));
    when(() => refreshTokenUseCase()).thenAnswer(
          (_) async => const ResultFailure(AuthFailure('The refresh token is invalid or has expired.')),
    );

    await tester.pumpWidget(MaterialApp.router(theme: AppTheme.dark(), routerConfig: buildRouter()));
    await tester.pumpAndSettle();

    expect(find.text('Login Screen'), findsOneWidget);
  });
}