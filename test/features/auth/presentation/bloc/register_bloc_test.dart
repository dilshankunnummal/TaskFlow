import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:taskflow/core/error/failures.dart';
import 'package:taskflow/core/error/result.dart';
import 'package:taskflow/features/auth/domain/entities/register_request.dart';
import 'package:taskflow/features/auth/domain/usecases/register_usecase.dart';
import 'package:taskflow/features/auth/presentation/bloc/register_bloc.dart';
import 'package:taskflow/features/auth/presentation/bloc/register_event.dart';
import 'package:taskflow/features/auth/presentation/bloc/register_state.dart';

class MockRegisterUseCase extends Mock implements RegisterUseCase {}

void main() {
  late MockRegisterUseCase useCase;

  setUpAll(() {
    registerFallbackValue(
      const RegisterRequest(fullName: 'Fallback', email: 'fallback@test.dev', password: 'Fallback1!'),
    );
  });

  setUp(() {
    useCase = MockRegisterUseCase();
  });

  const validEvent = RegisterSubmitted(
    fullName: 'Jordan Blake',
    email: 'jordan.blake@nimbusdigital.test',
    password: 'Passw0rd!',
    confirmPassword: 'Passw0rd!',
  );

  group('RegisterBloc', () {
    test('initial state is RegisterInitial', () {
      expect(RegisterBloc(useCase).state, const RegisterInitial());
    });

    blocTest<RegisterBloc, RegisterState>(
      'emits [RegisterLoading, RegisterSuccess] when registration succeeds',
      build: () {
        when(() => useCase(any())).thenAnswer((_) async => const Success(null));
        return RegisterBloc(useCase);
      },
      act: (bloc) => bloc.add(validEvent),
      expect: () => const [RegisterLoading(), RegisterSuccess()],
    );

    blocTest<RegisterBloc, RegisterState>(
      'emits [RegisterError] without loading when local validation fails',
      build: () => RegisterBloc(useCase),
      act: (bloc) => bloc.add(
        const RegisterSubmitted(fullName: 'Jo', email: 'not-an-email', password: 'weak', confirmPassword: 'weak'),
      ),
      expect: () => [isA<RegisterError>()],
      verify: (_) => verifyNever(() => useCase(any())),
    );

    blocTest<RegisterBloc, RegisterState>(
      'emits [RegisterLoading, RegisterError] when the repository reports a duplicate email',
      build: () {
        when(() => useCase(any())).thenAnswer(
              (_) async => const ResultFailure(ValidationFailure('Email already registered')),
        );
        return RegisterBloc(useCase);
      },
      act: (bloc) => bloc.add(validEvent),
      expect: () => const [
        RegisterLoading(),
        RegisterError(message: 'Email already registered', fieldErrors: {'email': 'Email already registered'}),
      ],
    );
  });
}