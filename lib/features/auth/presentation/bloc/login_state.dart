import 'package:equatable/equatable.dart';
import 'package:taskflow/features/auth/domain/entities/user_entity.dart';

sealed class LoginState extends Equatable {
  const LoginState({
    this.email = '',
    this.password = '',
    this.emailError,
    this.passwordError,
    this.obscurePassword = true,
    this.rememberMe = false,
  });

  final String email;
  final String password;
  final String? emailError;
  final String? passwordError;
  final bool obscurePassword;
  final bool rememberMe;

  @override
  List<Object?> get props => [email, password, emailError, passwordError, obscurePassword, rememberMe];
}

final class LoginInitial extends LoginState {
  const LoginInitial();
}

final class LoginEditing extends LoginState {
  const LoginEditing({
    required super.email,
    required super.password,
    super.emailError,
    super.passwordError,
    required super.obscurePassword,
    required super.rememberMe,
  });
}

final class LoginValid extends LoginState {
  const LoginValid({
    required super.email,
    required super.password,
    required super.obscurePassword,
    required super.rememberMe,
  });
}

final class LoginLoading extends LoginState {
  const LoginLoading({
    required super.email,
    required super.password,
    required super.obscurePassword,
    required super.rememberMe,
  });
}

final class LoginSuccess extends LoginState {
  const LoginSuccess({
    required this.user,
    required super.email,
    required super.password,
    required super.obscurePassword,
    required super.rememberMe,
  });

  final UserEntity user;

  @override
  List<Object?> get props => [...super.props, user];
}

final class LoginFailure extends LoginState {
  const LoginFailure({
    required this.message,
    required super.email,
    required super.password,
    required super.obscurePassword,
    required super.rememberMe,
  });

  final String message;

  @override
  List<Object?> get props => [...super.props, message];
}

final class LoginNavigateToDashboard extends LoginState {
  const LoginNavigateToDashboard({
    required super.email,
    required super.password,
    required super.obscurePassword,
    required super.rememberMe,
  });
}
