final class LoginRequest {
  const LoginRequest({required this.email, required this.password});

  final String email;
  final String password;

  @override
  String toString() => 'LoginRequest(email: $email, password: [REDACTED])';
}
