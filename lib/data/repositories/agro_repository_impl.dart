import '../../domain/entities/agro_entities.dart';
import '../../domain/repositories/agro_repository.dart';
import '../datasources/agro_remote_datasource.dart';

class AgroRepositoryImpl implements AgroRepository {
  AgroRepositoryImpl(this._datasource);
  final AgroRemoteDatasource _datasource;

  List<T> _mapList<T>(List<Map<String, dynamic>> data,
          T Function(Map<String, dynamic>) mapper) =>
      data.map(mapper).toList();

  double _toDouble(dynamic value) => (value as num?)?.toDouble() ?? 0;
  DateTime? _parseDate(dynamic value) =>
      value == null ? null : DateTime.tryParse(value.toString());

  @override
  Future<List<FarmEntity>> getFarms() async => _mapList(
      await _datasource.farms(),
      (j) => FarmEntity(
          id: '${j['id']}',
          name: j['name'] ?? '',
          owner: j['owner'] ?? '',
          city: j['city'] ?? '',
          state: j['state'] ?? ''));
  @override
  Future<List<FieldEntity>> getFields() async => _mapList(
      await _datasource.fields(),
      (j) => FieldEntity(
          id: '${j['id']}',
          name: j['name'] ?? '',
          farmId: '${j['farmId'] ?? ''}'));
  @override
  Future<List<CropEntity>> getCrops() async => _mapList(
      await _datasource.crops(),
      (j) => CropEntity(
          id: '${j['id']}',
          name: j['name'] ?? '',
          category: j['category'] ?? ''));
  @override
  Future<List<SeasonEntity>> getSeasons() async => _mapList(
      await _datasource.seasons(),
      (j) => SeasonEntity(
          id: '${j['id']}',
          name: j['name'] ?? '',
          year: (j['year'] as num?)?.toInt() ?? 0));
  @override
  Future<List<OperationEntity>> getOperations() async => _mapList(
      await _datasource.operations(),
      (j) => OperationEntity(
          id: '${j['id']}',
          type: j['type'] ?? '',
          description: j['description'] ?? ''));
  @override
  Future<List<MachineEntity>> getMachines() async =>
      _mapList(await _datasource.machines(), _mapMachine);

  @override
  Future<MachineEntity> createMachine(MachineInput input) async {
    final json = await _datasource.createMachine(
      _machinePayload(input),
      tenantId: input.tenantId,
    );
    return _mapMachine(json);
  }

  @override
  Future<MachineEntity> updateMachine(String id, MachineInput input) async {
    final json = await _datasource.updateMachine(id, _machinePayload(input));
    return _mapMachine(json);
  }

  @override
  Future<void> deleteMachine(String id) => _datasource.deleteMachine(id);
  @override
  Future<List<MachineRecordEntity>> getMachineRecords() async => _mapList(
      await _datasource.machineRecords(),
      (j) => MachineRecordEntity(
          id: '${j['id']}',
          machineId: '${j['machineId'] ?? ''}',
          recordType: j['recordType'] ?? ''));
  @override
  Future<List<FinancialEntryEntity>> getFinancialEntries() async => _mapList(
      await _datasource.financialEntries(),
      (j) => FinancialEntryEntity(
          id: '${j['id']}',
          type: j['type'] ?? '',
          description: j['description'] ?? '',
          value: (j['value'] as num?)?.toDouble() ?? 0));
  @override
  Future<List<SatelliteImageEntity>> getSatelliteImages() async => _mapList(
      await _datasource.satelliteImages(),
      (j) => SatelliteImageEntity(
          id: '${j['id']}',
          provider: j['provider'] ?? '',
          ndviAverage: (j['ndviAverage'] as num?)?.toDouble() ?? 0,
          thumbnailUrl: j['thumbnailUrl'] ?? ''));
  @override
  Future<AiResultEntity> getRiskAnalysis(Map<String, dynamic> input) async {
    final j = await _datasource.aiRisk(input);
    return AiResultEntity(
        score: (j['score'] as num?)?.toDouble() ?? 0,
        recommendations:
            (j['recommendations'] as List?)?.map((e) => '$e').toList() ?? []);
  }

  @override
  Future<List<FuelCreditEntity>> getFuelCredits({String? userId}) async {
    final query = {'userId': userId, 'size': 200};
    final data = await _datasource.fuelCredits(query: query);
    return _mapList(data, _mapFuelCredit);
  }

  @override
  Future<List<FuelSupplyEntity>> getFuelSupplies({String? userId}) async {
    final query = {'userId': userId, 'size': 200, 'sort': 'abastecidoEm,desc'};
    final data = await _datasource.fuelSupplies(query: query);
    return _mapList(data, _mapFuelSupply);
  }

  @override
  Future<FuelSupplyEntity> createFuelSupply(FuelSupplyInput input) async {
    final payload = {
      'userId': input.userId,
      'machineId': input.machineId,
      'valor': input.value,
      'litros': input.liters,
      'abastecidoEm': input.date.toUtc().toIso8601String(),
      'localizacao': input.location,
      'observacao': input.note,
    }..removeWhere((key, value) => value == null);
    final json = await _datasource.createFuelSupply(payload,
        tenantId: input.tenantId);
    return _mapFuelSupply(json);
  }

  FuelCreditEntity _mapFuelCredit(Map<String, dynamic> json) {
    return FuelCreditEntity(
      id: '${json['id']}',
      userId: '${json['userId']}',
      userName: json['userName'] ?? '',
      creditLimit: _toDouble(json['creditLimit']),
      balance: _toDouble(json['balance']),
      status: json['status'] ?? '',
      lastRechargeAt: _parseDate(json['lastRechargeAt']),
    );
  }

  FuelSupplyEntity _mapFuelSupply(Map<String, dynamic> json) {
    return FuelSupplyEntity(
      id: '${json['id']}',
      userId: '${json['userId']}',
      workerName: json['workerName'] ?? '',
      machineId: json['machineId']?.toString(),
      machineName: json['machineName'] as String?,
      liters: _toDouble(json['litros']),
      value: _toDouble(json['valor']),
      madeAt: _parseDate(json['abastecidoEm']) ?? DateTime.now(),
      location: json['localizacao'] as String?,
      note: json['observacao'] as String?,
    );
  }

  MachineEntity _mapMachine(Map<String, dynamic> json) {
    return MachineEntity(
      id: '${json['id']}',
      name: json['nome'] ?? '',
      code: json['codigo'] as String?,
      type: json['tipo']?.toString(),
      manufacturer: json['fabricante'] as String?,
      model: json['modelo'] as String?,
      year: (json['anoFabricacao'] as num?)?.toInt(),
      status: json['status']?.toString(),
      hourMeter: _toDouble(json['horimetroAtual']),
      notes: json['observacoes'] as String?,
      createdAt: _parseDate(json['createdAt']),
      updatedAt: _parseDate(json['updatedAt']),
      tenantId: json['tenantId']?.toString(),
    );
  }

  Map<String, dynamic> _machinePayload(MachineInput input) => {
        'codigo': input.code,
        'nome': input.name,
        'tipo': input.type,
        'fabricante': input.manufacturer,
        'modelo': input.model,
        'anoFabricacao': input.year,
        'status': input.status,
        'horimetroAtual': input.hourMeter,
        'observacoes': input.notes,
      }..removeWhere((_, value) => value == null);
}
