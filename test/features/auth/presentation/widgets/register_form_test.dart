import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:taskflow/core/constants/app_strings.dart';
import 'package:taskflow/features/auth/presentation/bloc/register_bloc.dart';
import 'package:taskflow/features/auth/presentation/bloc/register_event.dart';
import 'package:taskflow/features/auth/presentation/bloc/register_state.dart';
import 'package:taskflow/features/auth/presentation/widgets/register_form.dart';

import '../../../../test_utils/pump_app.dart';

class MockRegisterBloc extends MockBloc<RegisterEvent, RegisterState> implements RegisterBloc {}

void main() {
  late MockRegisterBloc bloc;

  setUp(() {
    bloc = MockRegisterBloc();
    whenListen(bloc, const Stream<RegisterState>.empty(), initialState: const RegisterInitial());
  });

  Widget buildSubject() {
    return BlocProvider<RegisterBloc>.value(value: bloc, child: const RegisterForm());
  }

  group('RegisterForm', () {
    testWidgets('renders all fields and the register button', (tester) async {
      await pumpApp(tester, buildSubject());

      expect(find.text(AppStrings.registerFullNameLabel), findsOneWidget);
      expect(find.text(AppStrings.registerEmailLabel), findsOneWidget);
      expect(find.text(AppStrings.registerPasswordLabel), findsOneWidget);
      expect(find.text(AppStrings.registerConfirmPasswordLabel), findsOneWidget);
      expect(find.text(AppStrings.registerButtonLabel), findsOneWidget);
    });

    testWidgets('shows validation messages when submitted empty', (tester) async {
      await pumpApp(tester, buildSubject());

      await tester.tap(find.text(AppStrings.registerButtonLabel));
      await tester.pumpAndSettle();

      expect(find.text('Full name is required.'), findsOneWidget);
      expect(find.text('Email is required.'), findsOneWidget);
      expect(find.text('Password is required.'), findsOneWidget);
      expect(find.text('Please confirm your password.'), findsOneWidget);
      verifyNever(() => bloc.add(any()));
    });

    testWidgets('shows a loading indicator while RegisterLoading', (tester) async {
      whenListen(bloc, const Stream<RegisterState>.empty(), initialState: const RegisterLoading());

      await pumpApp(tester, buildSubject());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}