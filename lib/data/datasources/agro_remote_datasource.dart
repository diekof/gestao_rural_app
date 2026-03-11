import 'package:dio/dio.dart';

import '../../core/constants/api_endpoints.dart';
import '../../core/storage/token_storage.dart';

class AgroRemoteDatasource {
  AgroRemoteDatasource(this._dio, this._tokenStorage);
  final Dio _dio;
  final TokenStorage _tokenStorage;

  Future<List<Map<String, dynamic>>> getList(String endpoint,
      {Map<String, dynamic>? query}) async {
    final response = await _dio.get(
      endpoint,
      queryParameters: _cleanQuery(query),
      options: await _authOptions(),
    );
    final data = response.data;
    if (data is List) {
      return data.cast<Map<String, dynamic>>();
    }
    if (data is Map<String, dynamic> && data['content'] is List) {
      return (data['content'] as List).cast<Map<String, dynamic>>();
    }
    throw StateError('Unexpected response for $endpoint');
  }

  Map<String, dynamic>? _cleanQuery(Map<String, dynamic>? source) {
    if (source == null) return null;
    final filtered = Map<String, dynamic>.from(source)
      ..removeWhere((_, value) => value == null);
    return filtered.isEmpty ? null : filtered;
  }

  Future<Map<String, dynamic>> post(String endpoint,
      Map<String, dynamic> payload,
      {Map<String, dynamic>? query}) async {
    final response = await _dio.post(
      endpoint,
      data: payload,
      queryParameters: _cleanQuery(query),
      options: await _authOptions(),
    );
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> put(String endpoint,
      Map<String, dynamic> payload,
      {Map<String, dynamic>? query}) async {
    final response = await _dio.put(
      endpoint,
      data: payload,
      queryParameters: _cleanQuery(query),
      options: await _authOptions(),
    );
    return response.data as Map<String, dynamic>;
  }

  Future<void> delete(String endpoint) async {
    await _dio.delete(endpoint, options: await _authOptions());
  }

  Future<List<Map<String, dynamic>>> farms() => getList(ApiEndpoints.farms);
  Future<List<Map<String, dynamic>>> fields() => getList(ApiEndpoints.fields);
  Future<List<Map<String, dynamic>>> crops() => getList(ApiEndpoints.crops);
  Future<List<Map<String, dynamic>>> seasons() => getList(ApiEndpoints.seasons);
  Future<List<Map<String, dynamic>>> operations() =>
      getList(ApiEndpoints.operations);
  Future<List<Map<String, dynamic>>> machines() =>
      getList(ApiEndpoints.machines);
  Future<Map<String, dynamic>> createMachine(Map<String, dynamic> payload,
          {String? tenantId}) =>
      post(ApiEndpoints.machines, payload, query: {'tenantId': tenantId});
  Future<Map<String, dynamic>> updateMachine(
          String id, Map<String, dynamic> payload) =>
      put('${ApiEndpoints.machines}/$id', payload);
  Future<void> deleteMachine(String id) =>
      delete('${ApiEndpoints.machines}/$id');
  Future<List<Map<String, dynamic>>> machineRecords() =>
      getList(ApiEndpoints.machineRecords);
  Future<List<Map<String, dynamic>>> financialEntries() =>
      getList(ApiEndpoints.financialEntries);
  Future<List<Map<String, dynamic>>> satelliteImages() =>
      getList(ApiEndpoints.satelliteImages);
  Future<List<Map<String, dynamic>>> fuelCredits(
          {Map<String, dynamic>? query}) =>
      getList(ApiEndpoints.fuelCredits, query: query);
  Future<List<Map<String, dynamic>>> fuelSupplies(
          {Map<String, dynamic>? query}) =>
      getList(ApiEndpoints.fuelSupplies, query: query);
  Future<Map<String, dynamic>> aiRisk(Map<String, dynamic> input) =>
      post(ApiEndpoints.aiRiskAnalysis, input);
  Future<Map<String, dynamic>> createFuelSupply(
          Map<String, dynamic> payload, {String? tenantId}) =>
      post(ApiEndpoints.fuelSupplies, payload,
          query: {'tenantId': tenantId});

  Future<Options> _authOptions() async {
    final token = await _tokenStorage.getAccessToken();
    if (token == null || token.isEmpty) {
      return Options();
    }
    return Options(headers: {'Authorization': 'Bearer $token'});
  }
}
