import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  const UserEntity({
    required this.id,
    this.tenantId,
    required this.name,
    required this.email,
    required this.username,
    required this.role,
    required this.status,
    this.lastLoginAt,
    this.createdAt,
    this.updatedAt,
    this.createdBy,
    this.updatedBy,
  });

  final String id;
  final String? tenantId;
  final String name;
  final String email;
  final String username;
  final String role;
  final String status;
  final DateTime? lastLoginAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? createdBy;
  final String? updatedBy;

  @override
  List<Object?> get props => [
        id,
        tenantId,
        name,
        email,
        username,
        role,
        status,
        lastLoginAt,
        createdAt,
        updatedAt,
        createdBy,
        updatedBy,
      ];
}
