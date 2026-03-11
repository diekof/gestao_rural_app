import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../presentation/modules/ai/ai_page.dart';
import '../presentation/modules/auth/login_page.dart';
import '../presentation/modules/auth/splash_page.dart';
import '../presentation/modules/crops/crops_page.dart';
import '../presentation/modules/dashboard/dashboard_page.dart';
import '../presentation/modules/farms/farms_page.dart';
import '../presentation/modules/fields/fields_page.dart';
import '../presentation/modules/financial/financial_page.dart';
import '../presentation/modules/fuel/fuel_page.dart';
import '../presentation/modules/home/home_page.dart';
import '../presentation/modules/machine_records/machine_records_page.dart';
import '../presentation/modules/machines/machines_page.dart';
import '../presentation/modules/operations/operations_page.dart';
import '../presentation/modules/satellite/satellite_page.dart';
import '../presentation/modules/seasons/seasons_page.dart';
import '../presentation/modules/settings/settings_page.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (_, __) => const SplashPage()),
      GoRoute(path: '/login', builder: (_, __) => const LoginPage()),
      GoRoute(path: '/home', builder: (_, __) => const HomePage()),
      GoRoute(path: '/dashboard', builder: (_, __) => const DashboardPage()),
      GoRoute(path: '/farms', builder: (_, __) => const FarmsPage()),
      GoRoute(path: '/farms/new', builder: (_, __) => const FarmFormPage()),
      GoRoute(path: '/fields', builder: (_, __) => const FieldsPage()),
      GoRoute(path: '/crops', builder: (_, __) => const CropsPage()),
      GoRoute(path: '/seasons', builder: (_, __) => const SeasonsPage()),
      GoRoute(path: '/operations', builder: (_, __) => const OperationsPage()),
      GoRoute(path: '/machines', builder: (_, __) => const MachinesPage()),
      GoRoute(
          path: '/machine-records',
          builder: (_, __) => const MachineRecordsPage()),
      GoRoute(path: '/fuel', builder: (_, __) => const FuelPage()),
      GoRoute(path: '/financial', builder: (_, __) => const FinancialPage()),
      GoRoute(path: '/ai', builder: (_, __) => const AiPage()),
      GoRoute(path: '/satellite', builder: (_, __) => const SatellitePage()),
      GoRoute(path: '/settings', builder: (_, __) => const SettingsPage()),
    ],
  );
});
