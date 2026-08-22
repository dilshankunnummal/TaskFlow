import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:taskflow/core/error/result.dart';
import 'package:taskflow/core/theme/app_theme.dart';
import 'package:taskflow/features/auth/domain/entities/register_request.dart';
import 'package:taskflow/features/auth/domain/usecases/register_usecase.dart';
import 'package:taskflow/features/auth/presentation/bloc/register_bloc.dart';
import 'package:taskflow/features/auth/presentation/pages/register_page.dart';

class MockRegisterUseCase extends Mock implements RegisterUseCase {}

void main() {
  final getIt = GetIt.instance;
  late MockRegisterUseCase useCase;

  setUpAll(() {
    registerFallbackValue(
      const RegisterRequest(fullName: 'Fallback', email: 'fallback@test.dev', password: 'Fallback1!'),
    );
  });

  setUp(() {
    useCase = MockRegisterUseCase();
    getIt
      ..reset()
      ..registerFactory<RegisterUseCase>(() => useCase)
      ..registerFactory<RegisterBloc>(() => RegisterBloc(getIt<RegisterUseCase>()));
  });

  tearDown(() async {
    await getIt.reset();
  });

  testWidgets('navigates to the login route after a successful registration', (tester) async {
    when(() => useCase(any())).thenAnswer((_) async => const Success(null));

    final router = GoRouter(
      initialLocation: '/register',
      routes: [
        GoRoute(path: '/register', builder: (context, state) => const RegisterPage()),
        GoRoute(path: '/login', builder: (context, state) => const Scaffold(body: Text('Login Screen'))),
      ],
    );

    await tester.pumpWidget(MaterialApp.router(theme: AppTheme.dark(), routerConfig: router));

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Jordan Blake');
    await tester.enterText(fields.at(1), 'jordan.blake@nimbusdigital.test');
    await tester.enterText(fields.at(2), 'Passw0rd!');
    await tester.enterText(fields.at(3), 'Passw0rd!');

    await tester.tap(find.text('Register'));
    await tester.pumpAndSettle();

    expect(find.text('Login Screen'), findsOneWidget);
  });
}