import 'package:equatable/equatable.dart';

final class UserEntity extends Equatable {
  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.orgId,
  });

  final String id;
  final String name;
  final String email;
  final String role;
  final String orgId;

  bool get isOrgAdmin => role == 'org_admin';

  @override
  List<Object?> get props => [id, name, email, role, orgId];
}
