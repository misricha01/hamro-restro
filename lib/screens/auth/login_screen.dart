import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/finance_form_fields.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  String? _emailError;
  String? _passwordError;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    setState(() {
      _emailError = email.isEmpty ? 'Email is required' : (_emailRegex.hasMatch(email) ? null : 'Enter a valid email address');
      _passwordError = password.isEmpty ? 'Password is required' : null;
    });

    if (_emailError != null || _passwordError != null) return;

    context.read<AuthProvider>().login(email: email, password: password);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight - 64),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 24),
                    Center(
                      child: Container(
                        width: 104,
                        height: 104,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(26),
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [AppTheme.primaryLight, AppTheme.primaryDark],
                          ),
                          boxShadow: [BoxShadow(color: AppTheme.primary.withValues(alpha: 0.45), blurRadius: 28, spreadRadius: 2)],
                        ),
                        child: const Icon(Icons.restaurant, color: Colors.white, size: 46),
                      ),
                    ),
                    const SizedBox(height: 22),
                    const Text(
                      'Hamro Restro',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 28, decoration: TextDecoration.none),
                    ),
                    const SizedBox(height: 48),

                    const FieldLabel(label: 'Email', required: false),
                    const SizedBox(height: 8),
                    AppTextField(
                      controller: _emailController,
                      hint: 'Enter your email',
                      keyboardType: TextInputType.emailAddress,
                      errorText: _emailError,
                      borderRadius: 30,
                      prefixIcon: const Icon(Icons.mail_outline, color: AppTheme.textSecondary),
                      onChanged: (_) {
                        if (_emailError != null) setState(() => _emailError = null);
                      },
                    ),
                    const SizedBox(height: 20),

                    const FieldLabel(label: 'Password', required: false),
                    const SizedBox(height: 8),
                    AppTextField(
                      controller: _passwordController,
                      hint: 'Enter your password',
                      obscureText: _obscurePassword,
                      errorText: _passwordError,
                      borderRadius: 30,
                      prefixIcon: const Icon(Icons.lock_outline, color: AppTheme.textSecondary),
                      onChanged: (_) {
                        if (_passwordError != null) setState(() => _passwordError = null);
                      },
                      suffixIcon: IconButton(
                        icon: Icon(_obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: AppTheme.textSecondary),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                    ),

                    if (auth.errorMessage != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: AppTheme.cancelled.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppTheme.cancelled),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline, color: AppTheme.cancelled, size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                auth.errorMessage!,
                                style: const TextStyle(color: AppTheme.cancelled, fontSize: 13, decoration: TextDecoration.none),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 32),
                    SizedBox(
                      height: 56,
                      child: ElevatedButton(
                        onPressed: auth.isLoggingIn ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          disabledBackgroundColor: AppTheme.primary.withValues(alpha: 0.6),
                          elevation: 6,
                          shadowColor: AppTheme.primary.withValues(alpha: 0.5),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        ),
                        child: auth.isLoggingIn
                            ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white))
                            : const Text('Login', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700, decoration: TextDecoration.none)),
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'Only authorized staff can login',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppTheme.textSecondary, fontSize: 12.5, decoration: TextDecoration.none),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: GestureDetector(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterScreen())),
                        child: const Text(
                          'New here? Create an account',
                          style: TextStyle(color: AppTheme.accent, fontSize: 13, fontWeight: FontWeight.w600, decoration: TextDecoration.none),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}