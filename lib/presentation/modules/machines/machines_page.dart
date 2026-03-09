import 'package:flutter/material.dart';

import '../../shared/widgets/module_scaffold.dart';

class MachinesPage extends StatelessWidget {
  const MachinesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ModuleScaffold(
      title: 'Máquinas',
      child: Center(child: Text('Listagem de máquinas')),
    );
  }
}
