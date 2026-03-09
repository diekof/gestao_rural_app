import '../../domain/entities/auth_session_entity.dart';
import '../../domain/entities/user_entity.dart';

class AuthSessionModel {
  AuthSessionModel({required this.accessToken, required this.refreshToken, required this.user});

  factory AuthSessionModel.fromJson(Map<String, dynamic> json) {
    return AuthSessionModel(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
    );
  }

  final String accessToken;
  final String refreshToken;
  final UserModel user;

  AuthSessionEntity toEntity() => AuthSessionEntity(accessToken: accessToken, refreshToken: refreshToken, user: user.toEntity());
}

class UserModel {
  UserModel({required this.id, required this.name, required this.email, this.tenantName});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'].toString(),
      name: json['name'] as String,
      email: json['email'] as String,
      tenantName: json['tenantName'] as String?,
    );
  }

  final String id;
  final String name;
  final String email;
  final String? tenantName;

  UserEntity toEntity() => UserEntity(id: id, name: name, email: email, tenantName: tenantName);
}
