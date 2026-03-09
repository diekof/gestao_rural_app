import '../../core/storage/token_storage.dart';
import '../../domain/entities/auth_session_entity.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._remoteDatasource, this._tokenStorage);

  final AuthRemoteDatasource _remoteDatasource;
  final TokenStorage _tokenStorage;

  @override
  Future<AuthSessionEntity> login({required String email, required String password}) async {
    final session = await _remoteDatasource.login(email, password);
    await _tokenStorage.saveTokens(accessToken: session.accessToken, refreshToken: session.refreshToken);
    return session.toEntity();
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    final accessToken = await _tokenStorage.getAccessToken();
    if (accessToken == null) return null;
    final me = await _remoteDatasource.me();
    return me.toEntity();
  }

  @override
  Future<void> logout() => _tokenStorage.clear();

  @override
  Future<String?> refreshToken() async {
    final refresh = await _tokenStorage.getRefreshToken();
    if (refresh == null) return null;
    final session = await _remoteDatasource.refresh(refresh);
    await _tokenStorage.saveTokens(accessToken: session.accessToken, refreshToken: session.refreshToken);
    return session.accessToken;
  }
}
