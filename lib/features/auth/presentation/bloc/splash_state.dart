import 'package:equatable/equatable.dart';

sealed class SplashState extends Equatable {
  const SplashState();

  @override
  List<Object?> get props => [];
}

final class SplashInitial extends SplashState {
  const SplashInitial();
}

final class SplashLoading extends SplashState {
  const SplashLoading();
}

final class Authenticated extends SplashState {
  const Authenticated();
}

final class Unauthenticated extends SplashState {
  const Unauthenticated();
}

final class SplashError extends SplashState {
  const SplashError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
