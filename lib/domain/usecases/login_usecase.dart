import '../entities/auth_session_entity.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase {
  LoginUseCase(this._repository);
  final AuthRepository _repository;

  Future<AuthSessionEntity> call(
      {required String usernameOrEmail, required String password}) {
    return _repository.login(
        usernameOrEmail: usernameOrEmail, password: password);
  }
}
