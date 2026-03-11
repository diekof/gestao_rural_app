import '../repositories/agro_repository.dart';

class DeleteMachineUseCase {
  DeleteMachineUseCase(this._repository);

  final AgroRepository _repository;

  Future<void> call(String id) => _repository.deleteMachine(id);
}
