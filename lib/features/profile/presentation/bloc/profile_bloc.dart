import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:taskflow/core/network/connectivity_manager.dart';
import 'package:taskflow/features/profile/domain/repositories/profile_repository.dart';
import 'package:taskflow/features/profile/domain/usecases/get_current_user_usecase.dart';
import 'package:taskflow/features/profile/presentation/bloc/profile_event.dart';
import 'package:taskflow/features/profile/presentation/bloc/profile_state.dart';

@injectable
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetCurrentUserUseCase _getCurrentUser;
  final ProfileRepository _profileRepository;
  final ConnectivityManager _connectivityManager;

  StreamSubscription<bool>? _connectivitySubscription;

  ProfileBloc(
    this._getCurrentUser,
    this._profileRepository,
    this._connectivityManager,
  ) : super(const ProfileInitial()) {
    on<LoadProfile>(_onLoadProfile);
    on<ToggleOfflineMode>(_onToggleOfflineMode);
    on<LogoutRequested>(_onLogoutRequested);

    _connectivitySubscription =
        _connectivityManager.onConnectivityChanged.listen((isOnline) {
      final current = state;
      final isOffline = !isOnline;
      if (current is ProfileSuccess && current.isOffline != isOffline) {
        add(ToggleOfflineMode(isOffline));
      }
    });
  }

  Future<void> _onLoadProfile(
    LoadProfile event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileLoading());
    final result = await _getCurrentUser();
    result.fold(
      (failure) => emit(ProfileError(failure.message)),
      (profile) => emit(ProfileSuccess(
        profile: profile,
        isOffline: !_connectivityManager.isOnline,
      )),
    );
  }

  void _onToggleOfflineMode(
    ToggleOfflineMode event,
    Emitter<ProfileState> emit,
  ) {
    if (_connectivityManager.isOnline == event.isOffline) {
      _connectivityManager.setOnline(!event.isOffline);
    }
    final current = state;
    if (current is ProfileSuccess && current.isOffline != event.isOffline) {
      emit(current.copyWith(isOffline: event.isOffline));
    }
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileLoading());
    final result = await _profileRepository.logout();
    result.fold(
      (failure) => emit(ProfileError(failure.message)),
      (_) => emit(const ProfileLogoutSuccess()),
    );
  }

  @override
  Future<void> close() {
    _connectivitySubscription?.cancel();
    return super.close();
  }
}
