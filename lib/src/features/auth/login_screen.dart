// Login Screen

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/cipherpoint_theme.dart';
import '../../auth/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(CPSpacing.xl),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: CPColors.bg800,
                      borderRadius: BorderRadius.circular(CPRadius.xl),
                      border: Border.all(color: CPColors.lineStrong),
                    ),
                    child: const Icon(Icons.person, color: CPColors.text, size: 40),
                  ),
                  const SizedBox(height: CPSpacing.xl),
                  Text('Welcome Back', style: CPTextStyles.displaySmall),
                  const SizedBox(height: CPSpacing.sm),
                  Text(
                    'Sign in to continue your OSINT journey',
                    style: CPTextStyles.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: CPSpacing.xxxl),
                  // Form
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _usernameController,
                          decoration: const InputDecoration(
                            labelText: 'Username',
                            prefixIcon: Icon(Icons.person_outline),
                          ),
                          textInputAction: TextInputAction.next,
                          validator: (v) => v?.isEmpty ?? true ? 'Username required' : null,
                        ),
                        const SizedBox(height: CPSpacing.lg),
                        TextFormField(
                          controller: _passwordController,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                            ),
                          ),
                          obscureText: _obscurePassword,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _submit(),
                          validator: (v) => v?.isEmpty ?? true ? 'Password required' : null,
                        ),
                        const SizedBox(height: CPSpacing.md),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () => context.push('/forgot-password'),
                            child: Text('Forgot password?', style: CPTextStyles.labelMedium),
                          ),
                        ),
                        const SizedBox(height: CPSpacing.xl),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: _isLoading ? null : _submit,
                            child: _isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF07111D)),
                                  )
                                : const Text('Sign In'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: CPSpacing.xl),
                  // Divider
                  Row(
                    children: [
                      const Expanded(child: Divider(color: CPColors.line)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: CPSpacing.md),
                        child: Text('OR', style: CPTextStyles.bodySmall),
                      ),
                      const Expanded(child: Divider(color: CPColors.line)),
                    ],
                  ),
                  const SizedBox(height: CPSpacing.lg),
                  // Telegram login
                  OutlinedButton.icon(
                    onPressed: () => _loginWithTelegram(),
                    icon: const Icon(Icons.telegram, color: Color(0xFF0088CC)),
                    label: Text('Continue with Telegram', style: CPTextStyles.labelLarge.copyWith(color: CPColors.text)),
                  ),
                  const SizedBox(height: CPSpacing.xl),
                  // Signup link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Don\'t have an account? ', style: CPTextStyles.bodyMedium),
                      TextButton(
                        onPressed: () => context.go('/signup'),
                        child: Text('Sign Up', style: CPTextStyles.labelLarge),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final success = await ref.read(authStateProvider.notifier).login(
      username: _usernameController.text.trim(),
      password: _passwordController.text,
    );

    setState(() => _isLoading = false);

    if (success && mounted) {
      context.go('/');
    } else if (mounted) {
      final error = ref.read(authStateProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error?.toString() ?? 'Login failed'),
          backgroundColor: CPColors.danger,
        ),
      );
    }
  }

  void _loginWithTelegram() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Telegram login not implemented yet')),
    );
  }
}