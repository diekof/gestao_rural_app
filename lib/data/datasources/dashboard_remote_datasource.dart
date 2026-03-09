import 'package:dio/dio.dart';

import '../../core/constants/api_endpoints.dart';
import '../models/dashboard_model.dart';

class DashboardRemoteDatasource {
  DashboardRemoteDatasource(this._dio);
  final Dio _dio;

  Future<DashboardModel> getOverview() async {
    final response = await _dio.get(ApiEndpoints.dashboardOverview);
    return DashboardModel.fromJson(response.data as Map<String, dynamic>);
  }
}
