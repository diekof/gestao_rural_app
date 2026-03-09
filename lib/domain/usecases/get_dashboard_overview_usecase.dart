import '../entities/dashboard_entity.dart';
import '../repositories/dashboard_repository.dart';

class GetDashboardOverviewUseCase {
  GetDashboardOverviewUseCase(this._repository);
  final DashboardRepository _repository;

  Future<DashboardEntity> call() => _repository.getOverview();
}
