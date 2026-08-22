final class RegisterRequest {
  const RegisterRequest({
    required this.fullName,
    required this.email,
    required this.password,
  });

  final String fullName;
  final String email;
  final String password;

  @override
  String toString() => 'RegisterRequest(fullName: $fullName, email: $email, password: [REDACTED])';
}