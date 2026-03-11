import '../entities/agro_entities.dart';
import '../repositories/agro_repository.dart';

class GetFuelSuppliesUseCase {
  GetFuelSuppliesUseCase(this._repository);
  final AgroRepository _repository;

  Future<List<FuelSupplyEntity>> call({String? userId}) {
    return _repository.getFuelSupplies(userId: userId);
  }
}
