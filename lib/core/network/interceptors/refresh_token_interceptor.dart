import 'package:dio/dio.dart';

typedef RefreshHandler = Future<String?> Function();

class RefreshTokenInterceptor extends Interceptor {
  RefreshTokenInterceptor(this._dio, this._refreshHandler);

  final Dio _dio;
  final RefreshHandler _refreshHandler;

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      final newToken = await _refreshHandler();
      if (newToken != null) {
        final request = err.requestOptions;
        request.headers['Authorization'] = 'Bearer $newToken';
        final response = await _dio.fetch(request);
        handler.resolve(response);
        return;
      }
    }
    handler.next(err);
  }
}
