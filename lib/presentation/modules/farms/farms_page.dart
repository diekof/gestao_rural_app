import 'package:flutter/material.dart';
class FarmsPage extends StatelessWidget { const FarmsPage({super.key}); @override Widget build(BuildContext context)=>const _CrudPage(title:'Fazendas'); }
class FarmFormPage extends StatelessWidget { const FarmFormPage({super.key}); @override Widget build(BuildContext context)=>const _CrudForm(title:'Cadastro de Fazenda'); }
class _CrudPage extends StatelessWidget { const _CrudPage({required this.title}); final String title; @override Widget build(BuildContext context)=>Scaffold(appBar: AppBar(title: Text(title)), body: const Center(child: Text('Listagem com busca, filtros e paginação.'))); }
class _CrudForm extends StatelessWidget { const _CrudForm({required this.title}); final String title; @override Widget build(BuildContext context)=>Scaffold(appBar: AppBar(title: Text(title)), body: const Padding(padding: EdgeInsets.all(16), child: Text('Formulário MVVM com validação.'))); }
