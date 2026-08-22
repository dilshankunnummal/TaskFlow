final class SessionModel {
  const SessionModel({
    required this.accessToken,
    required this.refreshToken,
    required this.accessTokenExpiresAt,
    required this.userId,
    required this.orgId,
    required this.role,
    required this.loginTimestamp,
  });

  final String accessToken;
  final String refreshToken;
  final DateTime accessTokenExpiresAt;
  final String userId;
  final String orgId;
  final String role;
  final DateTime loginTimestamp;

  @override
  String toString() {
    return 'SessionModel(userId: $userId, orgId: $orgId, role: $role, loginTimestamp: $loginTimestamp)';
  }
}
