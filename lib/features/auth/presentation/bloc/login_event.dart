sealed class LoginEvent {
  const LoginEvent();
}

final class EmailChanged extends LoginEvent {
  const EmailChanged(this.email);

  final String email;
}

final class PasswordChanged extends LoginEvent {
  const PasswordChanged(this.password);

  final String password;
}

final class PasswordVisibilityToggled extends LoginEvent {
  const PasswordVisibilityToggled();
}

final class RememberMeToggled extends LoginEvent {
  const RememberMeToggled(this.value);

  final bool value;
}

final class LoginSubmitted extends LoginEvent {
  const LoginSubmitted();
}
