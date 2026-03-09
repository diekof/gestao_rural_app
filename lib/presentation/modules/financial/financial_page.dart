import 'package:flutter/material.dart';

import '../../shared/widgets/module_scaffold.dart';

class FinancialPage extends StatelessWidget {
  const FinancialPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ModuleScaffold(
      title: 'Financeiro',
      child: Center(child: Text('Entradas financeiras com filtros')),
    );
  }
}
