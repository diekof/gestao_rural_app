import 'package:flutter/material.dart';

import '../../shared/widgets/module_scaffold.dart';

class OperationsPage extends StatelessWidget {
  const OperationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ModuleScaffold(
      title: 'Operações Agrícolas',
      child: Center(child: Text('Listagem de operações')),
    );
  }
}
