import '../entities/agro_entities.dart';
import '../repositories/agro_repository.dart';

class UpdateMachineUseCase {
  UpdateMachineUseCase(this._repository);

  final AgroRepository _repository;

  Future<MachineEntity> call(String id, MachineInput input) =>
      _repository.updateMachine(id, input);
}
