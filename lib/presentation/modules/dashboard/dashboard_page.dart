import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/states/view_state.dart';
import '../../shared/widgets/module_scaffold.dart';
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

  String _formatCurrency(double? value) {
    if (value == null) return '--';
    return 'R\$ ${value.toStringAsFixed(0)}';
  }

  String _formatInt(int? value) => value?.toString() ?? '--';

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(dashboardViewModelProvider);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final data = state.data;

    Widget child;
    if (state.status == ViewStatus.loading) {
      child = const Center(child: CircularProgressIndicator());
    } else if (state.status == ViewStatus.error) {
      child = Center(child: Text(state.message ?? 'Erro'));
    } else {
      final stats = [
        _DashboardStatData(
          label: 'Receita total',
          value: _formatCurrency(data?.totalRevenue),
          icon: Icons.trending_up,
          color: colors.primary,
        ),
        _DashboardStatData(
          label: 'Despesa total',
          value: _formatCurrency(data?.totalExpense),
          icon: Icons.trending_down,
          color: colors.tertiary,
        ),
        _DashboardStatData(
          label: 'Saldo liquido',
          value: _formatCurrency(data?.netBalance),
          icon: Icons.account_balance_wallet_outlined,
          color: colors.secondary,
        ),
        _DashboardStatData(
          label: 'Fazendas',
          value: _formatInt(data?.totalFarms),
          icon: Icons.agriculture_outlined,
          color: colors.secondaryContainer,
        ),
        _DashboardStatData(
          label: 'Talhoes',
          value: _formatInt(data?.totalFields),
          icon: Icons.terrain_outlined,
          color: colors.primaryContainer,
        ),
        _DashboardStatData(
          label: 'Operacoes no mes',
          value: _formatInt(data?.operationsCurrentMonth),
          icon: Icons.playlist_add_check_circle_outlined,
          color: colors.errorContainer,
        ),
      ];

      final quickActions = const [
        _QuickActionData(
          title: 'Registrar colheita',
          subtitle: 'Atualize o estoque',
          icon: Icons.local_florist_outlined,
        ),
        _QuickActionData(
          title: 'Agendar operacao',
          subtitle: 'Distribua equipes',
          icon: Icons.event_available_outlined,
        ),
        _QuickActionData(
          title: 'Conferir clima',
          subtitle: 'Evite surpresas',
          icon: Icons.cloud_outlined,
        ),
      ];

      child = RefreshIndicator(
        onRefresh: () => ref.read(dashboardViewModelProvider.notifier).load(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _DashboardHeroCard(
                colors: colors,
                textTheme: theme.textTheme,
                netBalance: _formatCurrency(data?.netBalance),
                operations: _formatInt(data?.operationsCurrentMonth),
              ),
              const SizedBox(height: 28),
              Text(
                'Principais indicadores',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Column(
                children: [
                  for (final stat in stats)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _DashboardStatCard(data: stat),
                    ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                'Atalhos rapidos',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              for (final action in quickActions)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _QuickActionCard(
                    data: action,
                    colors: colors,
                    textTheme: theme.textTheme,
                  ),
                ),
              const SizedBox(height: 24),
              Text(
                'Periodo analisado',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              const Row(
                children: [
                  Expanded(
                    child: _DashboardFilterField(
                      label: 'Selecione inicio',
                      icon: Icons.calendar_today_outlined,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: _DashboardFilterField(
                      label: 'Selecione fim',
                      icon: Icons.schedule,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _DashboardChartCard(colors: colors),
            ],
          ),
        ),
      );
    }

    return ModuleScaffold(
      title: 'Dashboard',
      child: child,
    );
  }
}

class _DashboardHeroCard extends StatelessWidget {
  const _DashboardHeroCard({
    required this.colors,
    required this.textTheme,
    required this.netBalance,
    required this.operations,
  });

  final ColorScheme colors;
  final TextTheme textTheme;
  final String netBalance;
  final String operations;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colors.primary,
            colors.primaryContainer,
            colors.tertiary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: colors.primary.withOpacity(0.25),
            blurRadius: 20,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Visao geral',
            style: textTheme.headlineSmall?.copyWith(
              color: colors.onPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Acompanhe o saldo liquido e as operacoes do mes.',
            style: textTheme.bodyMedium?.copyWith(
              color: colors.onPrimary.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _HeroInfoTile(
                  label: 'Saldo liquido',
                  value: netBalance,
                  icon: Icons.account_balance_wallet_outlined,
                  colors: colors,
                  textTheme: textTheme,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _HeroInfoTile(
                  label: 'Operacoes no mes',
                  value: operations,
                  icon: Icons.analytics_outlined,
                  colors: colors,
                  textTheme: textTheme,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroInfoTile extends StatelessWidget {
  const _HeroInfoTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.colors,
    required this.textTheme,
  });

  final String label;
  final String value;
  final IconData icon;
  final ColorScheme colors;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.onPrimary.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: colors.onPrimary.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: colors.onPrimary, size: 28),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: textTheme.bodySmall?.copyWith(
                    color: colors.onPrimary.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: textTheme.titleMedium?.copyWith(
                    color: colors.onPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardStatData {
  const _DashboardStatData({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;
}

class _DashboardStatCard extends StatelessWidget {
  const _DashboardStatCard({required this.data});

  final _DashboardStatData data;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: data.color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: data.color.withOpacity(0.18),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: data.color.withOpacity(0.25),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(data.icon, color: data.color, size: 28),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  data.value,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colors.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionData {
  const _QuickActionData({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;
}

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({
    required this.data,
    required this.colors,
    required this.textTheme,
  });

  final _QuickActionData data;
  final ColorScheme colors;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: colors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(data.icon, color: colors.primary, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.title,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colors.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  data.subtitle,
                  style: textTheme.bodyMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: colors.primary),
        ],
      ),
    );
  }
}

class _DashboardFilterField extends StatelessWidget {
  const _DashboardFilterField({
    required this.label,
    required this.icon,
  });

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Row(
        children: [
          Icon(icon, color: colors.onSurfaceVariant),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ),
          Icon(Icons.keyboard_arrow_down_rounded,
              color: colors.onSurfaceVariant),
        ],
      ),
    );
  }
}

class _DashboardChartCard extends StatelessWidget {
  const _DashboardChartCard({required this.colors});

  final ColorScheme colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withOpacity(0.1),
            blurRadius: 18,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Receita x Despesa',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 220,
            child: BarChart(
              BarChartData(
                gridData: FlGridData(show: false),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const labels = ['Jan', 'Fev', 'Mar', 'Abr'];
                        final index = value.toInt();
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child:
                              Text(index < labels.length ? labels[index] : ''),
                        );
                      },
                    ),
                  ),
                ),
                barGroups: [
                  BarChartGroupData(x: 0, barRods: [
                    BarChartRodData(
                        toY: 20, borderRadius: BorderRadius.circular(8))
                  ]),
                  BarChartGroupData(x: 1, barRods: [
                    BarChartRodData(
                        toY: 15, borderRadius: BorderRadius.circular(8))
                  ]),
                  BarChartGroupData(x: 2, barRods: [
                    BarChartRodData(
                        toY: 25, borderRadius: BorderRadius.circular(8))
                  ]),
                  BarChartGroupData(x: 3, barRods: [
                    BarChartRodData(
                        toY: 18, borderRadius: BorderRadius.circular(8))
                  ]),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
