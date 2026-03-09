import '../../shared/states/view_state.dart';

class AuthState extends ViewState<bool> {
  const AuthState({super.status, super.data, super.message, this.isAuthenticated = false});

  final bool isAuthenticated;

  AuthState copyWithAuth({ViewStatus? status, bool? isAuthenticated, String? message}) {
    return AuthState(
      status: status ?? this.status,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      message: message,
    );
  }
}
