import 'package:flutter/material.dart';

import '../../shared/widgets/module_scaffold.dart';

class FieldsPage extends StatelessWidget {
  const FieldsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ModuleScaffold(
      title: 'Talhões',
      child: Center(child: Text('Listagem de talhões')),
    );
  }
}
