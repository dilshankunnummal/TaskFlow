import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taskflow/core/utils/validators.dart';
import 'package:taskflow/features/auth/domain/usecases/login_usecase.dart';
import 'package:taskflow/features/auth/presentation/bloc/login_event.dart';
import 'package:taskflow/features/auth/presentation/bloc/login_state.dart';

final class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc(this._loginUseCase) : super(const LoginInitial()) {
    on<EmailChanged>(_onEmailChanged);
    on<PasswordChanged>(_onPasswordChanged);
    on<PasswordVisibilityToggled>(_onPasswordVisibilityToggled);
    on<RememberMeToggled>(_onRememberMeToggled);
    on<LoginSubmitted>(_onLoginSubmitted);
  }

  final LoginUseCase _loginUseCase;

  void _onEmailChanged(EmailChanged event, Emitter<LoginState> emit) {
    _emitValidated(
      emit,
      email: event.email,
      password: state.password,
      obscurePassword: state.obscurePassword,
      rememberMe: state.rememberMe,
    );
  }

  void _onPasswordChanged(PasswordChanged event, Emitter<LoginState> emit) {
    _emitValidated(
      emit,
      email: state.email,
      password: event.password,
      obscurePassword: state.obscurePassword,
      rememberMe: state.rememberMe,
    );
  }

  void _onPasswordVisibilityToggled(PasswordVisibilityToggled event, Emitter<LoginState> emit) {
    _emitValidated(
      emit,
      email: state.email,
      password: state.password,
      obscurePassword: !state.obscurePassword,
      rememberMe: state.rememberMe,
    );
  }

  void _onRememberMeToggled(RememberMeToggled event, Emitter<LoginState> emit) {
    _emitValidated(
      emit,
      email: state.email,
      password: state.password,
      obscurePassword: state.obscurePassword,
      rememberMe: event.value,
    );
  }

  Future<void> _onLoginSubmitted(LoginSubmitted event, Emitter<LoginState> emit) async {
    if (state is! LoginValid) {
      return;
    }

    final email = state.email;
    final password = state.password;
    final obscurePassword = state.obscurePassword;
    final rememberMe = state.rememberMe;

    emit(LoginLoading(email: email, password: password, obscurePassword: obscurePassword, rememberMe: rememberMe));

    final result = await _loginUseCase(email: email, password: password);

    result.fold(
      (failure) => emit(
        LoginFailure(
          message: failure.message,
          email: email,
          password: password,
          obscurePassword: obscurePassword,
          rememberMe: rememberMe,
        ),
      ),
      (user) {
        emit(
          LoginSuccess(
            user: user,
            email: email,
            password: password,
            obscurePassword: obscurePassword,
            rememberMe: rememberMe,
          ),
        );
        emit(
          LoginNavigateToDashboard(
            email: email,
            password: password,
            obscurePassword: obscurePassword,
            rememberMe: rememberMe,
          ),
        );
      },
    );
  }

  void _emitValidated(
    Emitter<LoginState> emit, {
    required String email,
    required String password,
    required bool obscurePassword,
    required bool rememberMe,
  }) {
    final emailError = Validators.email(email);
    final passwordError = Validators.password(password);
    final isValid = emailError == null && passwordError == null;

    if (isValid) {
      emit(LoginValid(email: email, password: password, obscurePassword: obscurePassword, rememberMe: rememberMe));
      return;
    }

    emit(
      LoginEditing(
        email: email,
        password: password,
        emailError: emailError,
        passwordError: passwordError,
        obscurePassword: obscurePassword,
        rememberMe: rememberMe,
      ),
    );
  }
}
