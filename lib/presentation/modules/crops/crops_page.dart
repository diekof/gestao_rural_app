import 'package:flutter/material.dart';

import '../../shared/widgets/module_scaffold.dart';

class CropsPage extends StatelessWidget {
  const CropsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ModuleScaffold(
      title: 'Culturas',
      child: Center(child: Text('Listagem de culturas')),
    );
  }
}
