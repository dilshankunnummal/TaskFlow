import 'package:equatable/equatable.dart';

sealed class RegisterState extends Equatable {
  const RegisterState();

  @override
  List<Object?> get props => [];
}

final class RegisterInitial extends RegisterState {
  const RegisterInitial();
}

final class RegisterLoading extends RegisterState {
  const RegisterLoading();
}

final class RegisterSuccess extends RegisterState {
  const RegisterSuccess();
}

final class RegisterError extends RegisterState {
  const RegisterError({required this.message, this.fieldErrors = const {}});

  final String message;
  final Map<String, String> fieldErrors;

  @override
  List<Object?> get props => [message, fieldErrors];
}