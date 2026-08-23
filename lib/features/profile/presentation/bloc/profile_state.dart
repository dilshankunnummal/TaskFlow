import 'package:equatable/equatable.dart';
import 'package:taskflow/features/profile/domain/entities/user_profile.dart';

sealed class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

final class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

final class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

final class ProfileSuccess extends ProfileState {
  final UserProfile profile;
  final bool isOffline;

  const ProfileSuccess({
    required this.profile,
    required this.isOffline,
  });

  ProfileSuccess copyWith({
    UserProfile? profile,
    bool? isOffline,
  }) {
    return ProfileSuccess(
      profile: profile ?? this.profile,
      isOffline: isOffline ?? this.isOffline,
    );
  }

  @override
  List<Object?> get props => [profile, isOffline];
}

final class ProfileLogoutSuccess extends ProfileState {
  const ProfileLogoutSuccess();
}

final class ProfileError extends ProfileState {
  final String message;

  const ProfileError(this.message);

  @override
  List<Object?> get props => [message];
}
