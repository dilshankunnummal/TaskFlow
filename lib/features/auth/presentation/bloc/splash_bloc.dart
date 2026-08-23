import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taskflow/features/auth/domain/entities/session_status.dart';
import 'package:taskflow/features/auth/domain/usecases/check_session_usecase.dart';
import 'package:taskflow/features/auth/domain/usecases/refresh_token_usecase.dart';
import 'package:taskflow/features/auth/presentation/bloc/splash_event.dart';
import 'package:taskflow/features/auth/presentation/bloc/splash_state.dart';

final class SplashBloc extends Bloc<SplashEvent, SplashState> {
  SplashBloc(this._checkSessionUseCase, this._refreshTokenUseCase) : super(const SplashInitial()) {
    on<CheckAuthenticationStatus>(_onCheckAuthenticationStatus);
  }

  final CheckSessionUseCase _checkSessionUseCase;
  final RefreshTokenUseCase _refreshTokenUseCase;

  Future<void> _onCheckAuthenticationStatus(
      CheckAuthenticationStatus event,
      Emitter<SplashState> emit,
      ) async {
    emit(const SplashLoading());

    final statusResult = await _checkSessionUseCase();

    await statusResult.fold(
          (failure) async => emit(SplashError(failure.message)),
          (status) => _handleStatus(status, emit),
    );
  }

  Future<void> _handleStatus(SessionStatus status, Emitter<SplashState> emit) async {
    switch (status) {
      case SessionStatus.valid:
        emit(const Authenticated());
      case SessionStatus.none:
        emit(const Unauthenticated());
      case SessionStatus.expired:
        final refreshResult = await _refreshTokenUseCase();
        refreshResult.fold(
              (failure) => emit(const Unauthenticated()),
              (_) => emit(const Authenticated()),
        );
    }
  }
}