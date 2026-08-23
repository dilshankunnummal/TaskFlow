import 'package:equatable/equatable.dart';

class UserProfile extends Equatable {
  final String id;
  final String name;
  final String email;
  final String? avatarUrl;
  final String organizationName;
  final String role;

  const UserProfile({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
    required this.organizationName,
    required this.role,
  });

  @override
  List<Object?> get props => [id, name, email, avatarUrl, organizationName, role];
}
