import 'package:flutter/material.dart';

import '../../shared/widgets/module_scaffold.dart';

class SatellitePage extends StatelessWidget {
  const SatellitePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ModuleScaffold(
      title: 'Satélite',
      child: Center(child: Text('Imagens e histórico NDVI')),
    );
  }
}
