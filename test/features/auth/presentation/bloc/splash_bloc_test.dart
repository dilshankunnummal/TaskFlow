import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:taskflow/core/error/failures.dart';
import 'package:taskflow/core/error/result.dart';
import 'package:taskflow/features/auth/domain/entities/session_status.dart';
import 'package:taskflow/features/auth/domain/usecases/check_session_usecase.dart';
import 'package:taskflow/features/auth/domain/usecases/refresh_token_usecase.dart';
import 'package:taskflow/features/auth/presentation/bloc/splash_bloc.dart';
import 'package:taskflow/features/auth/presentation/bloc/splash_event.dart';
import 'package:taskflow/features/auth/presentation/bloc/splash_state.dart';

class MockCheckSessionUseCase extends Mock implements CheckSessionUseCase {}

class MockRefreshTokenUseCase extends Mock implements RefreshTokenUseCase {}

void main() {
  late MockCheckSessionUseCase checkSessionUseCase;
  late MockRefreshTokenUseCase refreshTokenUseCase;

  setUp(() {
    checkSessionUseCase = MockCheckSessionUseCase();
    refreshTokenUseCase = MockRefreshTokenUseCase();
  });

  SplashBloc buildBloc() => SplashBloc(checkSessionUseCase, refreshTokenUseCase);

  group('SplashBloc', () {
    blocTest<SplashBloc, SplashState>(
      'emits [SplashLoading, Authenticated] for a valid session',
      build: () {
        when(() => checkSessionUseCase()).thenAnswer((_) async => const Success(SessionStatus.valid));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const CheckAuthenticationStatus()),
      expect: () => const [SplashLoading(), Authenticated()],
      verify: (_) => verifyNever(() => refreshTokenUseCase()),
    );

    blocTest<SplashBloc, SplashState>(
      'emits [SplashLoading, Unauthenticated] when there is no session',
      build: () {
        when(() => checkSessionUseCase()).thenAnswer((_) async => const Success(SessionStatus.none));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const CheckAuthenticationStatus()),
      expect: () => const [SplashLoading(), Unauthenticated()],
      verify: (_) => verifyNever(() => refreshTokenUseCase()),
    );

    blocTest<SplashBloc, SplashState>(
      'emits [SplashLoading, Authenticated] when an expired session refreshes successfully',
      build: () {
        when(() => checkSessionUseCase()).thenAnswer((_) async => const Success(SessionStatus.expired));
        when(() => refreshTokenUseCase()).thenAnswer((_) async => const Success(null));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const CheckAuthenticationStatus()),
      expect: () => const [SplashLoading(), Authenticated()],
    );

    blocTest<SplashBloc, SplashState>(
      'emits [SplashLoading, Unauthenticated] when an expired session fails to refresh',
      build: () {
        when(() => checkSessionUseCase()).thenAnswer((_) async => const Success(SessionStatus.expired));
        when(() => refreshTokenUseCase()).thenAnswer(
              (_) async => const ResultFailure(AuthFailure('The refresh token is invalid or has expired.')),
        );
        return buildBloc();
      },
      act: (bloc) => bloc.add(const CheckAuthenticationStatus()),
      expect: () => const [SplashLoading(), Unauthenticated()],
    );

    blocTest<SplashBloc, SplashState>(
      'emits [SplashLoading, SplashError] when checking the session itself fails',
      build: () {
        when(() => checkSessionUseCase()).thenAnswer(
              (_) async => const ResultFailure(CacheFailure('Unable to read the authentication session.')),
        );
        return buildBloc();
      },
      act: (bloc) => bloc.add(const CheckAuthenticationStatus()),
      expect: () => const [SplashLoading(), SplashError('Unable to read the authentication session.')],
    );
  });
}