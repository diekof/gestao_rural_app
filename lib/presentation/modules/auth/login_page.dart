import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';

import '../../shared/states/view_state.dart';
import 'auth_state.dart';
import 'auth_viewmodel.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();
  late final ProviderSubscription<AuthState> _authSubscription;
  var _obscurePassword = true;
  var _acceptTerms = true;

  @override
  void initState() {
    super.initState();
    _authSubscription =
        ref.listenManual<AuthState>(authViewModelProvider, (previous, next) {
      if (next.isAuthenticated) {
        if (mounted) context.go('/home');
        return;
      }
      final message = next.message;
      if (next.status == ViewStatus.error &&
          message != null &&
          message.isNotEmpty) {
        Fluttertoast.showToast(msg: message);
      }
    });
  }

  @override
  void dispose() {
    _authSubscription.close();
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  InputDecoration _fieldDecoration(
      {required String label, required IconData icon}) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.grey[700]),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(28),
        borderSide: const BorderSide(color: Color(0xffdfe8e3)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(28),
        borderSide: const BorderSide(color: Color(0xffdfe8e3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(28),
        borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary, width: 1.8),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authViewModelProvider);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xff8ed5ff), Color(0xff18a064)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _BrandCard(),
                const SizedBox(height: 24),
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: const [
                      BoxShadow(
                          color: Colors.black12,
                          blurRadius: 24,
                          offset: Offset(0, 10)),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text('hello!',
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                                    color: const Color(0xff03a87c),
                                    fontWeight: FontWeight.w700),
                            textAlign: TextAlign.center),
                        const SizedBox(height: 4),
                        Text('Faça login para continuar',
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(color: Colors.grey[600])),
                        const SizedBox(height: 32),
                        TextFormField(
                          controller: _identifierController,
                          decoration: _fieldDecoration(
                              label: 'Usuário ou e-mail',
                              icon: Icons.mail_outline),
                          validator: (v) => (v ?? '').isNotEmpty
                              ? null
                              : 'Informe usuário ou e-mail',
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _passwordController,
                          decoration: _fieldDecoration(
                                  label: 'Senha', icon: Icons.lock_outline)
                              .copyWith(
                            suffixIcon: IconButton(
                              icon: Icon(_obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility),
                              onPressed: () => setState(
                                  () => _obscurePassword = !_obscurePassword),
                            ),
                          ),
                          obscureText: _obscurePassword,
                          validator: (v) => (v ?? '').length >= 6
                              ? null
                              : 'Máximo 6 caracteres',
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Checkbox(
                              value: _acceptTerms,
                              onChanged: (value) =>
                                  setState(() => _acceptTerms = value ?? false),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6)),
                            ),
                            Expanded(
                              child: Text(
                                  'Concordo com os termos e condições de uso',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(color: Colors.grey[700])),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        FilledButton(
                          onPressed: state.status == ViewStatus.loading
                              ? null
                              : () async {
                                  if (!_acceptTerms) {
                                    Fluttertoast.showToast(
                                        msg: 'Aceite os termos para continuar');
                                    return;
                                  }
                                  if (_formKey.currentState!.validate()) {
                                    await ref
                                        .read(authViewModelProvider.notifier)
                                        .login(
                                          _identifierController.text.trim(),
                                          _passwordController.text,
                                        );
                                  }
                                },
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xff19c369),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(28)),
                          ),
                          child: state.status == ViewStatus.loading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: Colors.white))
                              : const Text('Entrar',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600)),
                        ),
                        const SizedBox(height: 20),
                        const Row(children: [
                          Expanded(child: Divider()),
                          Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8),
                              child: Text('OU',
                                  style: TextStyle(color: Colors.grey))),
                          Expanded(child: Divider())
                        ]),
                        const SizedBox(height: 16),
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _SocialButton(
                                color: Color(0xffe53935),
                                icon: Icons.g_mobiledata),
                            _SocialButton(
                                color: Color(0xffffb300),
                                icon: Icons.camera_alt_outlined),
                            _SocialButton(
                                color: Color(0xff1e88e5),
                                icon: Icons.facebook_rounded),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BrandCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 48),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.9),
            ),
            child: Icon(Icons.agriculture,
                size: 42, color: Theme.of(context).colorScheme.primary),
          ),
          const SizedBox(height: 16),
          const Text('Gestão Rural',
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
        ],
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({required this.color, required this.icon});

  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
                color: Colors.black26, blurRadius: 8, offset: Offset(0, 4))
          ]),
      child: Icon(icon, color: Colors.white, size: 30),
    );
  }
}
