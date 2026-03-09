import 'package:equatable/equatable.dart';

import 'user_entity.dart';

class AuthSessionEntity extends Equatable {
  const AuthSessionEntity({required this.accessToken, required this.refreshToken, required this.user});

  final String accessToken;
  final String refreshToken;
  final UserEntity user;

  @override
  List<Object?> get props => [accessToken, refreshToken, user];
}
