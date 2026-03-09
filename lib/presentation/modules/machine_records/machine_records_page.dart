import 'package:flutter/material.dart';

import '../../shared/widgets/module_scaffold.dart';

class MachineRecordsPage extends StatelessWidget {
  const MachineRecordsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ModuleScaffold(
      title: 'Registros de Máquinas',
      child: Center(child: Text('Listagem de registros')),
    );
  }
}
