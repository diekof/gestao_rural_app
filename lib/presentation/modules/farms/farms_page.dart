import 'package:flutter/material.dart';

import '../../shared/widgets/module_scaffold.dart';

class FarmsPage extends StatelessWidget {
  const FarmsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ModuleScaffold(
      title: 'Fazendas',
      child: Center(child: Text('Listagem com busca, filtros e paginação.')),
    );
  }
}

class FarmFormPage extends StatelessWidget {
  const FarmFormPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ModuleScaffold(
      title: 'Cadastro de Fazenda',
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Text('Formulário MVVM com validação.'),
      ),
    );
  }
}
