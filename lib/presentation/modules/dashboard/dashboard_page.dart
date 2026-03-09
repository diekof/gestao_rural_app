import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/states/view_state.dart';
import '../../shared/widgets/stat_card.dart';
import '../settings/settings_page.dart';
import 'dashboard_viewmodel.dart';

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(dashboardViewModelProvider.notifier).load());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(dashboardViewModelProvider);
    final data = state.data;
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      drawer: const SettingsDrawer(),
      body: state.status == ViewStatus.loading
          ? const Center(child: CircularProgressIndicator())
          : state.status == ViewStatus.error
              ? Center(child: Text(state.message ?? 'Erro'))
              : RefreshIndicator(
                  onRefresh: () => ref.read(dashboardViewModelProvider.notifier).load(),
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      Wrap(spacing: 12, runSpacing: 12, children: [
                        StatCard(title: 'Receita Total', value: 'R\$ ${data?.totalRevenue ?? 0}'),
                        StatCard(title: 'Despesa Total', value: 'R\$ ${data?.totalExpense ?? 0}'),
                        StatCard(title: 'Lucro Estimado', value: 'R\$ ${data?.estimatedProfit ?? 0}'),
                        StatCard(title: 'Fazendas', value: '${data?.totalFarms ?? 0}'),
                      ]),
                      const SizedBox(height: 24),
                      SizedBox(
                        height: 220,
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: BarChart(BarChartData(barGroups: [BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 20)]), BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 15)])])),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}
