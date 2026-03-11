import '../entities/agro_entities.dart';
import '../repositories/agro_repository.dart';

class CreateMachineUseCase {
  CreateMachineUseCase(this._repository);

  final AgroRepository _repository;

  Future<MachineEntity> call(MachineInput input) =>
      _repository.createMachine(input);
}
