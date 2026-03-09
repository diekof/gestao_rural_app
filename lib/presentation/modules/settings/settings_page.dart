import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../auth/auth_viewmodel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configurações')),
      body: ListView(children: [
        const ListTile(title: Text('Tema'), subtitle: Text('Claro / Escuro')),
        const ListTile(title: Text('Tenant atual'), subtitle: Text('Obtido via /auth/me')),
        ListTile(
          title: const Text('Logout'),
          onTap: () async {
            await ref.read(authViewModelProvider.notifier).logout();
            if (context.mounted) context.go('/login');
          },
        ),
      ]),
    );
  }
}

class SettingsDrawer extends StatelessWidget {
  const SettingsDrawer({super.key});

  @override
  Widget build(BuildContext context) => Drawer(
        child: ListView(
          children: [
            const DrawerHeader(child: Text('Gestão Rural SaaS')),
            _Item('Dashboard', '/dashboard'),
            _Item('Fazendas', '/farms'),
            _Item('Talhões', '/fields'),
            _Item('Culturas', '/crops'),
            _Item('Safras', '/seasons'),
            _Item('Operações', '/operations'),
            _Item('Máquinas', '/machines'),
            _Item('Registros', '/machine-records'),
            _Item('Financeiro', '/financial'),
            _Item('IA', '/ai'),
            _Item('Satélite', '/satellite'),
            _Item('Configurações', '/settings'),
          ],
        ),
      );
}

class _Item extends StatelessWidget {
  const _Item(this.title, this.route);
  final String title;
  final String route;

  @override
  Widget build(BuildContext context) => ListTile(title: Text(title), onTap: () => context.go(route));
}
