import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../domain/repositories/auth_repository.dart';
import '../../../domain/usecases/login_usecase.dart';
import '../../shared/states/view_state.dart';
import 'auth_state.dart';

final loginUseCaseProvider = Provider<LoginUseCase>(
    (ref) => LoginUseCase(ref.read(authRepositoryProvider)));

final authViewModelProvider =
    StateNotifierProvider<AuthViewModel, AuthState>((ref) {
  return AuthViewModel(
      ref.read(loginUseCaseProvider), ref.read(authRepositoryProvider));
});

class AuthViewModel extends StateNotifier<AuthState> {
  AuthViewModel(this._loginUseCase, this._authRepository)
      : super(const AuthState());

  final LoginUseCase _loginUseCase;
  final AuthRepository _authRepository;

  Future<void> restoreSession() async {
    state = state.copyWithAuth(status: ViewStatus.loading);
    final user = await _authRepository.getCurrentUser();
    state = state.copyWithAuth(
        status: ViewStatus.success, isAuthenticated: user != null);
  }

  Future<void> login(String usernameOrEmail, String password) async {
    try {
      state = state.copyWithAuth(status: ViewStatus.loading);
      await _loginUseCase(usernameOrEmail: usernameOrEmail, password: password);
      state =
          state.copyWithAuth(status: ViewStatus.success, isAuthenticated: true);
    } catch (e) {
      state = state.copyWithAuth(
          status: ViewStatus.error, message: 'Falha ao autenticar: ');
    }
  }

  Future<void> logout() async {
    await _authRepository.logout();
    state = state.copyWithAuth(status: ViewStatus.idle, isAuthenticated: false);
  }
}
