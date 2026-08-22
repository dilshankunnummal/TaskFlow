import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taskflow/core/error/failures.dart';
import 'package:taskflow/core/utils/validators.dart';
import 'package:taskflow/features/auth/domain/entities/register_request.dart';
import 'package:taskflow/features/auth/domain/usecases/register_usecase.dart';
import 'package:taskflow/features/auth/presentation/bloc/register_event.dart';
import 'package:taskflow/features/auth/presentation/bloc/register_state.dart';

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  RegisterBloc(this._registerUseCase) : super(const RegisterInitial()) {
    on<RegisterSubmitted>(_onRegisterSubmitted);
  }

  final RegisterUseCase _registerUseCase;

  Future<void> _onRegisterSubmitted(RegisterSubmitted event, Emitter<RegisterState> emit) async {
    final fieldErrors = _validate(event);
    if (fieldErrors.isNotEmpty) {
      emit(RegisterError(message: fieldErrors.values.first, fieldErrors: fieldErrors));
      return;
    }

    emit(const RegisterLoading());

    final result = await _registerUseCase(
      RegisterRequest(
        fullName: event.fullName.trim(),
        email: event.email.trim(),
        password: event.password,
      ),
    );

    result.fold(
          (failure) => emit(
        RegisterError(
          message: failure.message,
          fieldErrors: failure is ValidationFailure ? {'email': failure.message} : const {},
        ),
      ),
          (_) => emit(const RegisterSuccess()),
    );
  }

  Map<String, String> _validate(RegisterSubmitted event) {
    final errors = <String, String>{};

    final fullNameError = Validators.fullName(event.fullName);
    if (fullNameError != null) {
      errors['fullName'] = fullNameError;
    }

    final emailError = Validators.email(event.email);
    if (emailError != null) {
      errors['email'] = emailError;
    }

    final passwordError = Validators.strongPassword(event.password);
    if (passwordError != null) {
      errors['password'] = passwordError;
    }

    final confirmPasswordError = Validators.confirmPassword(event.confirmPassword, event.password);
    if (confirmPasswordError != null) {
      errors['confirmPassword'] = confirmPasswordError;
    }

    return errors;
  }
}