import 'package:taskflow/features/tasks/domain/entities/organization_member.dart';

class OrganizationMemberModel extends OrganizationMember {
  const OrganizationMemberModel({
    required super.id,
    required super.name,
    required super.email,
    super.avatarUrl,
    required super.role,
  });

  factory OrganizationMemberModel.fromJson(
    Map<String, dynamic> userJson, {
    required String role,
  }) {
    return OrganizationMemberModel(
      id: userJson['id'] as String,
      name: userJson['name'] as String,
      email: userJson['email'] as String,
      avatarUrl: userJson['avatar_url'] as String?,
      role: role,
    );
  }
}
