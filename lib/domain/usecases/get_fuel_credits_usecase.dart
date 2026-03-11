import '../entities/agro_entities.dart';
import '../repositories/agro_repository.dart';

class GetFuelCreditsUseCase {
  GetFuelCreditsUseCase(this._repository);
  final AgroRepository _repository;

  Future<List<FuelCreditEntity>> call({String? userId}) {
    return _repository.getFuelCredits(userId: userId);
  }
}
