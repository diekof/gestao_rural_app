import 'package:dio/dio.dart';

import '../../core/constants/api_endpoints.dart';

class AgroRemoteDatasource {
  AgroRemoteDatasource(this._dio);
  final Dio _dio;

  Future<List<Map<String, dynamic>>> getList(String endpoint) async {
    final response = await _dio.get(endpoint);
    return (response.data as List).cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> payload) async {
    final response = await _dio.post(endpoint, data: payload);
    return response.data as Map<String, dynamic>;
  }

  Future<List<Map<String, dynamic>>> farms() => getList(ApiEndpoints.farms);
  Future<List<Map<String, dynamic>>> fields() => getList(ApiEndpoints.fields);
  Future<List<Map<String, dynamic>>> crops() => getList(ApiEndpoints.crops);
  Future<List<Map<String, dynamic>>> seasons() => getList(ApiEndpoints.seasons);
  Future<List<Map<String, dynamic>>> operations() => getList(ApiEndpoints.operations);
  Future<List<Map<String, dynamic>>> machines() => getList(ApiEndpoints.machines);
  Future<List<Map<String, dynamic>>> machineRecords() => getList(ApiEndpoints.machineRecords);
  Future<List<Map<String, dynamic>>> financialEntries() => getList(ApiEndpoints.financialEntries);
  Future<List<Map<String, dynamic>>> satelliteImages() => getList(ApiEndpoints.satelliteImages);
  Future<Map<String, dynamic>> aiRisk(Map<String, dynamic> input) => post(ApiEndpoints.aiRiskAnalysis, input);
}
