import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _HeaderCard(),
              SizedBox(height: 24),
              Text('Modulos',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              SizedBox(height: 12),
              _ModulesGrid(),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
            colors: [Color(0xFF0B8F54), Color(0xFF0E603B)]),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Gestao Rural',
            style: theme.textTheme.headlineSmall
                ?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text('Solucoes para o campo',
              style:
                  theme.textTheme.bodyMedium?.copyWith(color: Colors.white70)),
          const SizedBox(height: 16),
          DecoratedBox(
            decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(16)),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Fazenda Mira',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w600)),
                  Icon(Icons.keyboard_arrow_down, color: Colors.white),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ModulesGrid extends StatelessWidget {
  const _ModulesGrid();

  static const List<_ModuleItem> _modules = [
    _ModuleItem('Dashboard', '/dashboard', Icons.dashboard_customize),
    _ModuleItem('Fazendas', '/farms', Icons.park_outlined),
    _ModuleItem('Talhoes', '/fields', Icons.crop_rounded),
    _ModuleItem('Culturas', '/crops', Icons.spa_outlined),
    _ModuleItem('Safras', '/seasons', Icons.eco_outlined),
    _ModuleItem('Operacoes', '/operations', Icons.handyman_outlined),
    _ModuleItem('Maquinas', '/machines', Icons.agriculture),
    _ModuleItem('Registros', '/machine-records', Icons.receipt_long),
    _ModuleItem('Financeiro', '/financial', Icons.attach_money),
    _ModuleItem('IA', '/ai', Icons.psychology_alt_outlined),
    _ModuleItem('Satelite', '/satellite', Icons.satellite_alt),
    _ModuleItem('Configuracoes', '/settings', Icons.settings_suggest_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.05,
      ),
      itemCount: _modules.length,
      itemBuilder: (context, index) {
        final module = _modules[index];
        return _ModuleCard(module: module);
      },
    );
  }
}

class _ModuleItem {
  const _ModuleItem(this.title, this.route, this.icon);

  final String title;
  final String route;
  final IconData icon;
}

class _ModuleCard extends StatelessWidget {
  const _ModuleCard({required this.module});

  final _ModuleItem module;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () => context.go(module.route),
      child: Ink(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: Colors.white,
          boxShadow: const [
            BoxShadow(
                color: Colors.black12, blurRadius: 12, offset: Offset(0, 6)),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: const Color(0xFFE7F5EF),
                child:
                    Icon(module.icon, color: const Color(0xFF0B8F54), size: 28),
              ),
              const SizedBox(height: 12),
              Text(module.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}
