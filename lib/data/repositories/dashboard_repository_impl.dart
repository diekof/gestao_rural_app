import '../../domain/entities/dashboard_entity.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../datasources/dashboard_remote_datasource.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  DashboardRepositoryImpl(this._datasource);
  final DashboardRemoteDatasource _datasource;

  @override
  Future<DashboardEntity> getOverview() async => (await _datasource.getOverview()).toEntity();
}
