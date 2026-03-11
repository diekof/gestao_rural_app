import '../entities/agro_entities.dart';

abstract class AgroRepository {
  Future<List<FarmEntity>> getFarms();
  Future<List<FieldEntity>> getFields();
  Future<List<CropEntity>> getCrops();
  Future<List<SeasonEntity>> getSeasons();
  Future<List<OperationEntity>> getOperations();
  Future<List<MachineEntity>> getMachines();
  Future<List<MachineRecordEntity>> getMachineRecords();
  Future<List<FinancialEntryEntity>> getFinancialEntries();
  Future<List<SatelliteImageEntity>> getSatelliteImages();
  Future<AiResultEntity> getRiskAnalysis(Map<String, dynamic> input);
  Future<List<FuelCreditEntity>> getFuelCredits({String? userId});
  Future<List<FuelSupplyEntity>> getFuelSupplies({String? userId});
  Future<FuelSupplyEntity> createFuelSupply(FuelSupplyInput input);
}
