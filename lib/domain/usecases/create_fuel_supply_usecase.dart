import '../entities/agro_entities.dart';
import '../repositories/agro_repository.dart';

class CreateFuelSupplyUseCase {
  CreateFuelSupplyUseCase(this._repository);
  final AgroRepository _repository;

  Future<FuelSupplyEntity> call(FuelSupplyInput input) {
    return _repository.createFuelSupply(input);
  }
}
