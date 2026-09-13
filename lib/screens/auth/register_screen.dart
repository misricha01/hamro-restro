import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/finance_form_fields.dart';

/// `POST /api/auth/register` -- simple signup form, matching [LoginScreen]'s
/// visual style.
///
/// NOTE: the created account has no restaurant attached (see the comment on
/// [AuthProvider.register]) -- what happens right after a successful
/// register hasn't been confirmed live. Test this screen end-to-end before
/// relying on it.
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _fullnameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _positionController = TextEditingController();
  final _emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  String? _fullnameError;
  String? _emailError;
  String? _passwordError;
  String? _positionError;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _fullnameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _positionController.dispose();
    super.dispose();
  }

  void _submit() {
    final fullname = _fullnameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final position = _positionController.text.trim();

    setState(() {
      _fullnameError = fullname.isEmpty ? 'Full name is required' : null;
      _emailError = email.isEmpty ? 'Email is required' : (_emailRegex.hasMatch(email) ? null : 'Enter a valid email address');
      _passwordError = password.isEmpty ? 'Password is required' : (password.length < 6 ? 'Use at least 6 characters' : null);
      _positionError = position.isEmpty ? 'Position is required' : null;
    });

    if (_fullnameError != null || _emailError != null || _passwordError != null || _positionError != null) return;

    context.read<AuthProvider>().register(fullname: fullname, email: email, password: password, position: position);
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
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Row(
                          children: const [
                            Icon(Icons.chevron_left, color: AppTheme.accent),
                            Text('Back to login', style: TextStyle(color: AppTheme.accent, fontSize: 14, decoration: TextDecoration.none)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: Container(
                        width: 88,
                        height: 88,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(22),
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [AppTheme.primaryLight, AppTheme.primaryDark],
                          ),
                          boxShadow: [BoxShadow(color: AppTheme.primary.withValues(alpha: 0.45), blurRadius: 24, spreadRadius: 2)],
                        ),
                        child: const Icon(Icons.restaurant, color: Colors.white, size: 40),
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'Create Account',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 26, decoration: TextDecoration.none),
                    ),
                    const SizedBox(height: 32),

                    const FieldLabel(label: 'Full Name', required: true),
                    const SizedBox(height: 8),
                    AppTextField(
                      controller: _fullnameController,
                      hint: 'Enter your full name',
                      errorText: _fullnameError,
                      borderRadius: 30,
                      prefixIcon: const Icon(Icons.person_outline, color: AppTheme.textSecondary),
                      onChanged: (_) {
                        if (_fullnameError != null) setState(() => _fullnameError = null);
                      },
                    ),
                    const SizedBox(height: 20),

                    const FieldLabel(label: 'Email', required: true),
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

                    const FieldLabel(label: 'Position', required: true),
                    const SizedBox(height: 8),
                    AppTextField(
                      controller: _positionController,
                      hint: 'e.g. Restaurant Staff',
                      errorText: _positionError,
                      borderRadius: 30,
                      prefixIcon: const Icon(Icons.badge_outlined, color: AppTheme.textSecondary),
                      onChanged: (_) {
                        if (_positionError != null) setState(() => _positionError = null);
                      },
                    ),
                    const SizedBox(height: 20),

                    const FieldLabel(label: 'Password', required: true),
                    const SizedBox(height: 8),
                    AppTextField(
                      controller: _passwordController,
                      hint: 'Create a password',
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
                        onPressed: auth.isRegistering ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          disabledBackgroundColor: AppTheme.primary.withValues(alpha: 0.6),
                          elevation: 6,
                          shadowColor: AppTheme.primary.withValues(alpha: 0.5),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        ),
                        child: auth.isRegistering
                            ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white))
                            : const Text('Create Account', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700, decoration: TextDecoration.none)),
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