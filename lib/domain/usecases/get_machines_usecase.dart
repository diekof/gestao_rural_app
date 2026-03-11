import '../entities/agro_entities.dart';
import '../repositories/agro_repository.dart';

class GetMachinesUseCase {
  GetMachinesUseCase(this._repository);

  final AgroRepository _repository;

  Future<List<MachineEntity>> call() => _repository.getMachines();
}
