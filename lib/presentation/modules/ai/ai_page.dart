import 'package:flutter/material.dart';

import '../../shared/widgets/module_scaffold.dart';

class AiPage extends StatelessWidget {
  const AiPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ModuleScaffold(
      title: 'IA Agro',
      child: Center(child: Text('Previsão e análise de risco')),
    );
  }
}
