import 'package:flutter_test/flutter_test.dart';
import 'package:gestao_rural_app/domain/entities/auth_session_entity.dart';
import 'package:gestao_rural_app/domain/entities/user_entity.dart';
import 'package:gestao_rural_app/domain/repositories/auth_repository.dart';
import 'package:gestao_rural_app/domain/usecases/login_usecase.dart';
import 'package:gestao_rural_app/presentation/modules/auth/auth_viewmodel.dart';

class FakeAuthRepository implements AuthRepository {
  @override
  Future<UserEntity?> getCurrentUser() async => const UserEntity(
        id: '1',
        tenantId: 't1',
        name: 'Ana',
        email: 'ana@agro.com',
        username: 'ana',
        role: 'MANAGER',
        status: 'ACTIVE',
      );

  @override
  Future<AuthSessionEntity> login(
          {required String usernameOrEmail, required String password}) async =>
      const AuthSessionEntity(accessToken: 'a', refreshToken: 'r');

  @override
  Future<void> logout() async {}

  @override
  Future<String?> refreshToken() async => 'a2';
}

void main() {
  test('login success updates auth state', () async {
    final repo = FakeAuthRepository();
    final vm = AuthViewModel(LoginUseCase(repo), repo);
    await vm.login('ana@agro.com', '123456');
    expect(vm.state.isAuthenticated, true);
  });
}
