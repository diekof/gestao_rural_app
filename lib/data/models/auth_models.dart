import '../../domain/entities/auth_session_entity.dart';
import '../../domain/entities/user_entity.dart';

class AuthSessionModel {
  AuthSessionModel({required this.accessToken, required this.refreshToken});

  factory AuthSessionModel.fromJson(Map<String, dynamic> json) {
    return AuthSessionModel(
      accessToken: json['accessToken'] as String? ?? '',
      refreshToken: json['refreshToken'] as String? ?? '',
    );
  }

  final String accessToken;
  final String refreshToken;

  AuthSessionEntity toEntity() =>
      AuthSessionEntity(accessToken: accessToken, refreshToken: refreshToken);
}

class UserModel {
  UserModel({
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

  factory UserModel.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(String? value) =>
        value == null ? null : DateTime.tryParse(value);

    return UserModel(
      id: json['id']?.toString() ?? '',
      tenantId: json['tenantId']?.toString(),
      name: json['nome'] as String? ?? '',
      email: json['email'] as String? ?? '',
      username: json['username'] as String? ?? '',
      role: json['role'] as String? ?? '',
      status: json['status'] as String? ?? '',
      lastLoginAt: parseDate(json['lastLoginAt'] as String?),
      createdAt: parseDate(json['createdAt'] as String?),
      updatedAt: parseDate(json['updatedAt'] as String?),
      createdBy: json['createdBy'] as String?,
      updatedBy: json['updatedBy'] as String?,
    );
  }

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

  UserEntity toEntity() => UserEntity(
        id: id,
        tenantId: tenantId,
        name: name,
        email: email,
        username: username,
        role: role,
        status: status,
        lastLoginAt: lastLoginAt,
        createdAt: createdAt,
        updatedAt: updatedAt,
        createdBy: createdBy,
        updatedBy: updatedBy,
      );
}
