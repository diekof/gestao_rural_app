import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../data/providers/agro_providers.dart';
import '../../../domain/entities/agro_entities.dart';
import '../../../domain/entities/user_entity.dart';
import '../../../domain/repositories/agro_repository.dart';
import '../../../domain/repositories/auth_repository.dart';
import '../../../domain/usecases/create_fuel_supply_usecase.dart';
import '../../../domain/usecases/get_fuel_credits_usecase.dart';
import '../../../domain/usecases/get_fuel_supplies_usecase.dart';
import '../../shared/states/view_state.dart';

final getFuelCreditsUseCaseProvider = Provider<GetFuelCreditsUseCase>(
  (ref) => GetFuelCreditsUseCase(ref.read(agroRepositoryProvider)),
);
final getFuelSuppliesUseCaseProvider = Provider<GetFuelSuppliesUseCase>(
  (ref) => GetFuelSuppliesUseCase(ref.read(agroRepositoryProvider)),
);
final createFuelSupplyUseCaseProvider = Provider<CreateFuelSupplyUseCase>(
  (ref) => CreateFuelSupplyUseCase(ref.read(agroRepositoryProvider)),
);

final fuelModuleViewModelProvider =
    StateNotifierProvider<FuelModuleViewModel, ViewState<FuelModuleData>>(
        (ref) => FuelModuleViewModel(
              ref.read(getFuelCreditsUseCaseProvider),
              ref.read(getFuelSuppliesUseCaseProvider),
              ref.read(createFuelSupplyUseCaseProvider),
              ref.read(agroRepositoryProvider),
              ref.read(authRepositoryProvider),
            ));

class FuelModuleData {
  const FuelModuleData({
    required this.credits,
    required this.supplies,
    required this.machines,
    this.currentUser,
    this.filterUserId,
  });

  final List<FuelCreditEntity> credits;
  final List<FuelSupplyEntity> supplies;
  final List<MachineEntity> machines;
  final UserEntity? currentUser;
  final String? filterUserId;

  bool get isManager => _isManager(currentUser);

  FuelCreditEntity? get myCredit => creditForUser(currentUser?.id);

  FuelCreditEntity? creditForUser(String? userId) {
    if (userId == null) return null;
    for (final credit in credits) {
      if (credit.userId == userId) return credit;
    }
    return null;
  }

  static bool _isManager(UserEntity? user) {
    final role = user?.role;
    return role == 'TENANT_ADMIN' || role == 'MANAGER';
  }
}

class FuelModuleViewModel extends StateNotifier<ViewState<FuelModuleData>> {
  FuelModuleViewModel(
    this._getFuelCredits,
    this._getFuelSupplies,
    this._createFuelSupply,
    this._agroRepository,
    this._authRepository,
  ) : super(const ViewState());

  final GetFuelCreditsUseCase _getFuelCredits;
  final GetFuelSuppliesUseCase _getFuelSupplies;
  final CreateFuelSupplyUseCase _createFuelSupply;
  final AgroRepository _agroRepository;
  final AuthRepository _authRepository;

  Future<void> load({String? userFilter}) async {
    try {
      state = state.copyWith(status: ViewStatus.loading, message: null);
      final user = await _authRepository.getCurrentUser();
      final credits = await _getFuelCredits();
      final filter = userFilter ?? _defaultFilter(user);
      final supplies = await _getFuelSupplies(userId: filter);
      final machines = await _agroRepository.getMachines();
      state = state.copyWith(
        status: ViewStatus.success,
        data: FuelModuleData(
          credits: credits,
          supplies: supplies,
          machines: machines,
          currentUser: user,
          filterUserId: filter,
        ),
      );
    } catch (e) {
      state = state.copyWith(
          status: ViewStatus.error,
          message: 'Falha ao carregar abastecimentos: $e');
    }
  }

  Future<void> refresh() => load(userFilter: state.data?.filterUserId);

  Future<void> filterByUser(String? userId) => load(userFilter: userId);

  Future<void> submit(FuelSupplyInput input) async {
    try {
      state = state.copyWith(status: ViewStatus.loading, message: null);
      await _createFuelSupply(input);
      await load(userFilter: input.userId ?? state.data?.filterUserId);
    } catch (e) {
      state = state.copyWith(
          status: ViewStatus.error,
          message: 'Falha ao registrar abastecimento: $e');
      rethrow;
    }
  }

  String? _defaultFilter(UserEntity? user) {
    if (user == null) return null;
    return FuelModuleData._isManager(user) ? null : user.id;
  }
}
