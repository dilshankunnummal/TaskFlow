import 'package:equatable/equatable.dart';

sealed class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

final class LoadProfile extends ProfileEvent {
  const LoadProfile();
}

final class ToggleOfflineMode extends ProfileEvent {
  final bool isOffline;

  const ToggleOfflineMode(this.isOffline);

  @override
  List<Object?> get props => [isOffline];
}

final class LogoutRequested extends ProfileEvent {
  const LogoutRequested();
}
