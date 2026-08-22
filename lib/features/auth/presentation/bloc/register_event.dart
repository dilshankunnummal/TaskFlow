sealed class RegisterEvent {
  const RegisterEvent();
}

final class RegisterSubmitted extends RegisterEvent {
  const RegisterSubmitted({
    required this.fullName,
    required this.email,
    required this.password,
    required this.confirmPassword,
  });

  final String fullName;
  final String email;
  final String password;
  final String confirmPassword;
}