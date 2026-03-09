import '../../domain/entities/agro_entities.dart';
import '../../domain/repositories/agro_repository.dart';
import '../datasources/agro_remote_datasource.dart';

class AgroRepositoryImpl implements AgroRepository {
  AgroRepositoryImpl(this._datasource);
  final AgroRemoteDatasource _datasource;

  List<T> _mapList<T>(List<Map<String, dynamic>> data, T Function(Map<String, dynamic>) mapper) => data.map(mapper).toList();

  @override
  Future<List<FarmEntity>> getFarms() async => _mapList(await _datasource.farms(), (j) => FarmEntity(id: '${j['id']}', name: j['name'] ?? '', owner: j['owner'] ?? '', city: j['city'] ?? '', state: j['state'] ?? ''));
  @override
  Future<List<FieldEntity>> getFields() async => _mapList(await _datasource.fields(), (j) => FieldEntity(id: '${j['id']}', name: j['name'] ?? '', farmId: '${j['farmId'] ?? ''}'));
  @override
  Future<List<CropEntity>> getCrops() async => _mapList(await _datasource.crops(), (j) => CropEntity(id: '${j['id']}', name: j['name'] ?? '', category: j['category'] ?? ''));
  @override
  Future<List<SeasonEntity>> getSeasons() async => _mapList(await _datasource.seasons(), (j) => SeasonEntity(id: '${j['id']}', name: j['name'] ?? '', year: (j['year'] as num?)?.toInt() ?? 0));
  @override
  Future<List<OperationEntity>> getOperations() async => _mapList(await _datasource.operations(), (j) => OperationEntity(id: '${j['id']}', type: j['type'] ?? '', description: j['description'] ?? ''));
  @override
  Future<List<MachineEntity>> getMachines() async => _mapList(await _datasource.machines(), (j) => MachineEntity(id: '${j['id']}', name: j['name'] ?? '', type: j['type'] ?? ''));
  @override
  Future<List<MachineRecordEntity>> getMachineRecords() async => _mapList(await _datasource.machineRecords(), (j) => MachineRecordEntity(id: '${j['id']}', machineId: '${j['machineId'] ?? ''}', recordType: j['recordType'] ?? ''));
  @override
  Future<List<FinancialEntryEntity>> getFinancialEntries() async => _mapList(await _datasource.financialEntries(), (j) => FinancialEntryEntity(id: '${j['id']}', type: j['type'] ?? '', description: j['description'] ?? '', value: (j['value'] as num?)?.toDouble() ?? 0));
  @override
  Future<List<SatelliteImageEntity>> getSatelliteImages() async => _mapList(await _datasource.satelliteImages(), (j) => SatelliteImageEntity(id: '${j['id']}', provider: j['provider'] ?? '', ndviAverage: (j['ndviAverage'] as num?)?.toDouble() ?? 0, thumbnailUrl: j['thumbnailUrl'] ?? ''));
  @override
  Future<AiResultEntity> getRiskAnalysis(Map<String, dynamic> input) async { final j = await _datasource.aiRisk(input); return AiResultEntity(score: (j['score'] as num?)?.toDouble() ?? 0, recommendations: (j['recommendations'] as List?)?.map((e) => '$e').toList() ?? []); }
}
