import '../entities/auth_session_entity.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<AuthSessionEntity> login({required String email, required String password});
  Future<UserEntity?> getCurrentUser();
  Future<String?> refreshToken();
  Future<void> logout();
}
