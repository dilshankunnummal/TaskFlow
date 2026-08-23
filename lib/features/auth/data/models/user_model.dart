import 'package:taskflow/features/auth/domain/entities/user_entity.dart';

final class UserModel {
  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.orgId,
  });

  factory UserModel.fromJson(
    Map<String, dynamic> json, {
    required String orgId,
    required String role,
  }) {
    return UserModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      role: role,
      orgId: orgId,
    );
  }

  final String id;
  final String name;
  final String email;
  final String role;
  final String orgId;

  UserEntity toEntity() {
    return UserEntity(id: id, name: name, email: email, role: role, orgId: orgId);
  }
}
