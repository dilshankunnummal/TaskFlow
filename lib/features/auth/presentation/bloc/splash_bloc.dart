import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taskflow/features/auth/domain/repositories/auth_repository.dart';
import 'package:taskflow/features/auth/presentation/bloc/splash_event.dart';
import 'package:taskflow/features/auth/presentation/bloc/splash_state.dart';

final class SplashBloc extends Bloc<SplashEvent, SplashState> {
  SplashBloc(this._authRepository) : super(const SplashInitial()) {
    on<CheckAuthenticationStatus>(_onCheckAuthenticationStatus);
  }

  final AuthRepository _authRepository;

  Future<void> _onCheckAuthenticationStatus(
      CheckAuthenticationStatus event,
      Emitter<SplashState> emit,
      ) async {
    emit(const SplashLoading());

    final result = await _authRepository.checkAuthenticationStatus();

    result.fold(
          (failure) => emit(SplashFailure(failure.message)),
          (isAuthenticated) => emit(isAuthenticated ? const Authenticated() : const Unauthenticated()),
    );
  }
}