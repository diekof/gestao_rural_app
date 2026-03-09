import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../shared/widgets/module_scaffold.dart';
import '../auth/auth_viewmodel.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ModuleScaffold(
      title: 'Configurações',
      child: ListView(
        children: [
          const ListTile(title: Text('Tema'), subtitle: Text('Claro / Escuro')),
          const ListTile(
              title: Text('Tenant atual'),
              subtitle: Text('Obtido via /auth/me')),
          ListTile(
            title: const Text('Logout'),
            onTap: () async {
              await ref.read(authViewModelProvider.notifier).logout();
              if (context.mounted) context.go('/login');
            },
          ),
        ],
      ),
    );
  }
}
