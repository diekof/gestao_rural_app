import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../storage/token_storage.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/refresh_token_interceptor.dart';

Dio _createBaseDio() {
  final dio = Dio(BaseOptions(baseUrl: 'http://localhost:8080'));
  dio.interceptors.add(LogInterceptor(responseBody: true, requestBody: true));
  return dio;
}

final loggerProvider = Provider<Logger>((ref) => Logger());
final secureStorageProvider = Provider<FlutterSecureStorage>((ref) => const FlutterSecureStorage());
final tokenStorageProvider = Provider<TokenStorage>((ref) => TokenStorage(ref.read(secureStorageProvider)));

final apiClientProvider = Provider<Dio>((ref) {
  final dio = _createBaseDio();
  final tokenStorage = ref.read(tokenStorageProvider);
  dio.interceptors.add(AuthInterceptor(tokenStorage));
  dio.interceptors.add(
    RefreshTokenInterceptor(dio, () async {
      final authRepo = ref.read(authRepositoryProvider);
      return authRepo.refreshToken();
    }),
  );
  return dio;
});

final authRemoteDatasourceProvider = Provider<AuthRemoteDatasource>((ref) {
  return AuthRemoteDatasource(_createBaseDio());
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(ref.read(authRemoteDatasourceProvider), ref.read(tokenStorageProvider));
});
