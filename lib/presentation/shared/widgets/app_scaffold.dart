import 'package:flutter/material.dart';

class AppScaffold extends StatelessWidget {
  const AppScaffold({super.key, required this.title, required this.body, this.fab});
  final String title;
  final Widget body;
  final Widget? fab;

  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: Text(title)), body: body, floatingActionButton: fab);
}
