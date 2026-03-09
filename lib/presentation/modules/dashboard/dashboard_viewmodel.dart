import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../data/datasources/dashboard_remote_datasource.dart';
import '../../../data/repositories/dashboard_repository_impl.dart';
import '../../../domain/entities/dashboard_entity.dart';
import '../../../domain/usecases/get_dashboard_overview_usecase.dart';
import '../../shared/states/view_state.dart';

final dashboardRemoteDatasourceProvider = Provider<DashboardRemoteDatasource>((ref) => DashboardRemoteDatasource(ref.read(apiClientProvider)));
final dashboardRepositoryProvider = Provider<DashboardRepositoryImpl>((ref) => DashboardRepositoryImpl(ref.read(dashboardRemoteDatasourceProvider)));
final dashboardUseCaseProvider = Provider<GetDashboardOverviewUseCase>((ref) => GetDashboardOverviewUseCase(ref.read(dashboardRepositoryProvider)));
final dashboardViewModelProvider = StateNotifierProvider<DashboardViewModel, ViewState<DashboardEntity>>((ref) => DashboardViewModel(ref.read(dashboardUseCaseProvider)));

class DashboardViewModel extends StateNotifier<ViewState<DashboardEntity>> {
  DashboardViewModel(this._usecase) : super(const ViewState());
  final GetDashboardOverviewUseCase _usecase;

  Future<void> load() async {
    try {
      state = state.copyWith(status: ViewStatus.loading);
      final data = await _usecase();
      state = state.copyWith(status: ViewStatus.success, data: data);
    } catch (e) {
      state = state.copyWith(status: ViewStatus.error, message: 'Erro ao carregar dashboard: $e');
    }
  }
}
