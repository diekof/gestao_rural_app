import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/states/view_state.dart';
import '../../shared/widgets/module_scaffold.dart';
import '../../shared/widgets/stat_card.dart';
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
    Future.microtask(
        () => ref.read(dashboardViewModelProvider.notifier).load());
  }

  String _currency(double? value) => 'R\$ ';
  String _intValue(int? value) => '';

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(dashboardViewModelProvider);
    final data = state.data;

    Widget child;
    if (state.status == ViewStatus.loading) {
      child = const Center(child: CircularProgressIndicator());
    } else if (state.status == ViewStatus.error) {
      child = Center(child: Text(state.message ?? 'Erro'));
    } else {
      child = RefreshIndicator(
        onRefresh: () => ref.read(dashboardViewModelProvider.notifier).load(),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                StatCard(
                    title: 'Receita Total',
                    value: _currency(data?.totalRevenue)),
                StatCard(
                    title: 'Despesa Total',
                    value: _currency(data?.totalExpense)),
                StatCard(
                    title: 'Saldo Líquido', value: _currency(data?.netBalance)),
                StatCard(title: 'Fazendas', value: _intValue(data?.totalFarms)),
                StatCard(title: 'Talhões', value: _intValue(data?.totalFields)),
                StatCard(
                    title: 'Safras Ativas',
                    value: _intValue(data?.activeSeasons)),
                StatCard(
                    title: 'Operações no mês',
                    value: _intValue(data?.operationsCurrentMonth)),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 220,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: BarChart(
                    BarChartData(
                      barGroups: [
                        BarChartGroupData(
                            x: 0, barRods: [BarChartRodData(toY: 20)]),
                        BarChartGroupData(
                            x: 1, barRods: [BarChartRodData(toY: 15)]),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return ModuleScaffold(
      title: 'Dashboard',
      child: child,
    );
  }
}
