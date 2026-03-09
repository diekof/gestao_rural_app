import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../shared/states/view_state.dart';
import 'auth_viewmodel.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authViewModelProvider);
    ref.listen(authViewModelProvider, (previous, next) {
      if (next.isAuthenticated) context.go('/dashboard');
    });

    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Gestão Rural', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 24),
                  TextFormField(controller: _emailController, decoration: const InputDecoration(labelText: 'E-mail'), validator: (v) => v!.contains('@') ? null : 'E-mail inválido'),
                  const SizedBox(height: 12),
                  TextFormField(controller: _passwordController, decoration: const InputDecoration(labelText: 'Senha'), obscureText: true, validator: (v) => (v ?? '').length >= 6 ? null : 'Mínimo 6 caracteres'),
                  const SizedBox(height: 20),
                  if (state.status == ViewStatus.error) Text(state.message ?? 'Erro', style: const TextStyle(color: Colors.red)),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: state.status == ViewStatus.loading
                          ? null
                          : () async {
                              if (_formKey.currentState!.validate()) {
                                await ref.read(authViewModelProvider.notifier).login(_emailController.text.trim(), _passwordController.text);
                              }
                            },
                      child: state.status == ViewStatus.loading ? const CircularProgressIndicator() : const Text('Entrar'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
