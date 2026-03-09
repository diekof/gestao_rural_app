import 'package:flutter_test/flutter_test.dart';
import 'package:gestao_rural_app/domain/entities/auth_session_entity.dart';
import 'package:gestao_rural_app/domain/entities/user_entity.dart';
import 'package:gestao_rural_app/domain/repositories/auth_repository.dart';
import 'package:gestao_rural_app/domain/usecases/login_usecase.dart';
import 'package:gestao_rural_app/presentation/modules/auth/auth_viewmodel.dart';

class FakeAuthRepository implements AuthRepository {
  @override
  Future<UserEntity?> getCurrentUser() async => const UserEntity(id: '1', name: 'Ana', email: 'ana@agro.com');

  @override
  Future<AuthSessionEntity> login({required String email, required String password}) async => AuthSessionEntity(
        accessToken: 'a',
        refreshToken: 'r',
        user: UserEntity(id: '1', name: 'Ana', email: email),
      );

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
