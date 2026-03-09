import 'package:flutter/material.dart';

import '../../shared/widgets/module_scaffold.dart';

class SeasonsPage extends StatelessWidget {
  const SeasonsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ModuleScaffold(
      title: 'Safras',
      child: Center(child: Text('Listagem de safras')),
    );
  }
}
