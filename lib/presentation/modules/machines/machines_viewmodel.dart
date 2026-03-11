import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../data/providers/agro_providers.dart';
import '../../../domain/entities/agro_entities.dart';
import '../../../domain/entities/user_entity.dart';
import '../../../domain/repositories/auth_repository.dart';
import '../../../domain/usecases/create_machine_usecase.dart';
import '../../../domain/usecases/delete_machine_usecase.dart';
import '../../../domain/usecases/get_machines_usecase.dart';
import '../../../domain/usecases/update_machine_usecase.dart';
import '../../shared/states/view_state.dart';

final getMachinesUseCaseProvider = Provider<GetMachinesUseCase>(
  (ref) => GetMachinesUseCase(ref.read(agroRepositoryProvider)),
);

final createMachineUseCaseProvider = Provider<CreateMachineUseCase>(
  (ref) => CreateMachineUseCase(ref.read(agroRepositoryProvider)),
);

final updateMachineUseCaseProvider = Provider<UpdateMachineUseCase>(
  (ref) => UpdateMachineUseCase(ref.read(agroRepositoryProvider)),
);

final deleteMachineUseCaseProvider = Provider<DeleteMachineUseCase>(
  (ref) => DeleteMachineUseCase(ref.read(agroRepositoryProvider)),
);

final machinesViewModelProvider =
    StateNotifierProvider<MachinesViewModel, ViewState<MachinesStateData>>(
  (ref) => MachinesViewModel(
    ref.read(getMachinesUseCaseProvider),
    ref.read(createMachineUseCaseProvider),
    ref.read(updateMachineUseCaseProvider),
    ref.read(deleteMachineUseCaseProvider),
    ref.read(authRepositoryProvider),
  ),
);

class MachinesViewModel extends StateNotifier<ViewState<MachinesStateData>> {
  MachinesViewModel(
    this._getMachines,
    this._createMachine,
    this._updateMachine,
    this._deleteMachine,
    this._authRepository,
  ) : super(const ViewState());

  final GetMachinesUseCase _getMachines;
  final CreateMachineUseCase _createMachine;
  final UpdateMachineUseCase _updateMachine;
  final DeleteMachineUseCase _deleteMachine;
  final AuthRepository _authRepository;
  UserEntity? _currentUser;

  Future<void> load() async {
    try {
      state = state.copyWith(status: ViewStatus.loading, message: null);
      _currentUser ??= await _authRepository.getCurrentUser();
      final machines = await _getMachines();
      state = state.copyWith(
        status: ViewStatus.success,
        data: MachinesStateData(
          machines: machines,
          currentUser: _currentUser,
        ),
        message: null,
      );
    } catch (e) {
      state = state.copyWith(
        status: ViewStatus.error,
        message: 'Falha ao carregar maquinas: $e',
      );
    }
  }

  Future<void> refresh() => load();

  Future<void> createMachine(MachineInput input) async {
    await _runMutation(() => _createMachine(input));
  }

  Future<void> updateMachine(String id, MachineInput input) async {
    await _runMutation(() => _updateMachine(id, input));
  }

  Future<void> deleteMachine(String id) async {
    await _runMutation(() => _deleteMachine(id));
  }

  Future<void> _runMutation(Future<void> Function() action) async {
    try {
      state = state.copyWith(status: ViewStatus.loading, message: null);
      await action();
      final machines = await _getMachines();
      state = state.copyWith(
        status: ViewStatus.success,
        data: MachinesStateData(
          machines: machines,
          currentUser: _currentUser,
        ),
        message: null,
      );
    } catch (e) {
      state = state.copyWith(
        status: ViewStatus.error,
        message: 'Acao com maquina falhou: $e',
      );
      rethrow;
    }
  }
}

class MachinesStateData {
  const MachinesStateData({
    required this.machines,
    required this.currentUser,
  });

  final List<MachineEntity> machines;
  final UserEntity? currentUser;

  bool get isSuperAdmin =>
      (currentUser?.role ?? '').toUpperCase() == 'SUPER_ADMIN';
  String? get tenantId => currentUser?.tenantId;
}
