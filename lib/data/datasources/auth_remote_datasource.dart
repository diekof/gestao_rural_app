import 'package:dio/dio.dart';

import '../../core/constants/api_endpoints.dart';
import '../models/auth_models.dart';

class AuthRemoteDatasource {
  AuthRemoteDatasource(this._dio);
  final Dio _dio;

  Future<AuthSessionModel> login(
      String usernameOrEmail, String password) async {
    final response = await _dio.post(
      ApiEndpoints.authLogin,
      data: {'usernameOrEmail': usernameOrEmail, 'password': password},
    );
    return AuthSessionModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<AuthSessionModel> refresh(String refreshToken) async {
    final response = await _dio
        .post(ApiEndpoints.authRefresh, data: {'refreshToken': refreshToken});
    return AuthSessionModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<UserModel> me(String accessToken) async {
    final response = await _dio.get(
      ApiEndpoints.authMe,
      options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
    );
    return UserModel.fromJson(response.data as Map<String, dynamic>);
  }
}
