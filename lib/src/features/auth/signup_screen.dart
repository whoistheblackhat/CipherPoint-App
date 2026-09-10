// Signup Screen

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/cipherpoint_theme.dart';
import '../../auth/auth_provider.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _agreeTerms = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
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
                  Text('Join CipherPoint', style: CPTextStyles.displaySmall),
                  const SizedBox(height: CPSpacing.sm),
                  Text(
                    'Create your analyst profile and start hunting',
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
                            helperText: '3-20 characters, alphanumeric',
                          ),
                          textInputAction: TextInputAction.next,
                          validator: (v) {
                            if (v?.isEmpty ?? true) return 'Username required';
                            if (v!.length < 3 || v.length > 20) return '3-20 characters';
                            if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(v)) return 'Alphanumeric only';
                            return null;
                          },
                        ),
                        const SizedBox(height: CPSpacing.lg),
                        TextFormField(
                          controller: _emailController,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            prefixIcon: Icon(Icons.email_outlined),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          validator: (v) {
                            if (v?.isEmpty ?? true) return 'Email required';
                            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v!)) {
                              return 'Invalid email';
                            }
                            return null;
                          },
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
                            helperText: 'Min 8 characters',
                          ),
                          obscureText: _obscurePassword,
                          textInputAction: TextInputAction.next,
                          validator: (v) {
                            if (v?.isEmpty ?? true) return 'Password required';
                            if (v!.length < 8) return 'Min 8 characters';
                            return null;
                          },
                        ),
                        const SizedBox(height: CPSpacing.lg),
                        TextFormField(
                          controller: _confirmController,
                          decoration: InputDecoration(
                            labelText: 'Confirm Password',
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(_obscureConfirm ? Icons.visibility : Icons.visibility_off),
                              onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                            ),
                          ),
                          obscureText: _obscureConfirm,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _submit(),
                          validator: (v) => v == _passwordController.text ? null : 'Passwords must match',
                        ),
                        const SizedBox(height: CPSpacing.lg),
                        // Terms checkbox
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Checkbox(
                              value: _agreeTerms,
                              onChanged: (v) => setState(() => _agreeTerms = v ?? false),
                              activeColor: CPColors.primary,
                              checkColor: const Color(0xFF07111D),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => _agreeTerms = !_agreeTerms),
                                child: RichText(
                                  text: TextSpan(
                                    style: CPTextStyles.bodySmall,
                                    children: [
                                      const TextSpan(text: 'I agree to the '),
                                      TextSpan(
                                        text: 'Terms of Service',
                                        style: CPTextStyles.bodySmall.copyWith(color: CPColors.primary),
                                      ),
                                      const TextSpan(text: ' and '),
                                      TextSpan(
                                        text: 'Privacy Policy',
                                        style: CPTextStyles.bodySmall.copyWith(color: CPColors.primary),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: CPSpacing.xl),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: _isLoading || !_agreeTerms ? null : _submit,
                            child: _isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF07111D)),
                                  )
                                : const Text('Create Account'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: CPSpacing.xl),
                  // Login link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Already have an account? ', style: CPTextStyles.bodyMedium),
                      TextButton(
                        onPressed: () => context.go('/login'),
                        child: Text('Sign In', style: CPTextStyles.labelLarge),
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
    if (!_agreeTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please accept terms and privacy policy')),
      );
      return;
    }
    setState(() => _isLoading = true);

    final success = await ref.read(authStateProvider.notifier).signup(
      username: _usernameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    setState(() => _isLoading = false);

    if (success && mounted) {
      context.go('/');
    } else if (mounted) {
      final error = ref.read(authStateProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error?.toString() ?? 'Signup failed'),
          backgroundColor: CPColors.danger,
        ),
      );
    }
  }
}