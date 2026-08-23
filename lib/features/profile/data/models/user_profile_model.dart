import 'package:taskflow/features/profile/domain/entities/user_profile.dart';

class UserProfileModel extends UserProfile {
  const UserProfileModel({
    required super.id,
    required super.name,
    required super.email,
    super.avatarUrl,
    required super.organizationName,
    required super.role,
  });

  factory UserProfileModel.fromJson(
    Map<String, dynamic> userJson, {
    required String organizationName,
    required String role,
  }) {
    return UserProfileModel(
      id: userJson['id'] as String,
      name: userJson['name'] as String,
      email: userJson['email'] as String,
      avatarUrl: userJson['avatar_url'] as String?,
      organizationName: organizationName,
      role: role,
    );
  }
}
