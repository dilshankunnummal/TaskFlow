import 'package:taskflow/features/auth/data/models/user_model.dart';

final class LoginResponse {
  const LoginResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresInSeconds,
    required this.user,
  });

  final String accessToken;
  final String refreshToken;
  final int expiresInSeconds;
  final UserModel user;

  @override
  String toString() => 'LoginResponse(user: ${user.email}, expiresInSeconds: $expiresInSeconds)';
}
