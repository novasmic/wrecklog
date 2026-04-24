import 'dart:async';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../app_services.dart';
import '../services/analytics_service.dart';
import '../services/auth_service.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isLogin = true;
  bool _loading = false;
  bool _obscure = true;
  bool _obscureConfirm = true; // ignore: prefer_final_fields
  String? _error;

  final _emailCtrl    = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl  = TextEditingController();
  final _formKey      = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() { _loading = true; _error = null; });
    try {
      if (_isLogin) {
        await auth.signIn(_emailCtrl.text.trim(), _passwordCtrl.text);
        unawaited(AnalyticsService.logSignIn());
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Welcome back!')),
          );
          Navigator.of(context).pop();
        }
      } else {
        await auth.register(_emailCtrl.text.trim(), _passwordCtrl.text);
        unawaited(AnalyticsService.logSignIn());
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Account created! Your data will now sync across devices.')),
          );
          Navigator.of(context).pop();
        }
      }
    } catch (e) {
      if (mounted) setState(() => _error = AuthService.friendlyError(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _resetPassword() async {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty) {
      setState(() => _error = 'Enter your email address above first.');
      return;
    }
    try {
      await auth.sendPasswordReset(email);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password reset email sent.')),
        );
      }
    } catch (e) {
      if (mounted) setState(() => _error = AuthService.friendlyError(e));
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Logo / title
                    Icon(Icons.directions_car_rounded, size: 56, color: scheme.primary),
                    const SizedBox(height: 16),
                    Text(
                      'WreckLog',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _isLogin ? 'Sign in to your account' : 'Create your account',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurface.withValues(alpha:0.6),
                      ),
                    ),
                    if (!_isLogin) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: scheme.primary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'Your account syncs your vehicles and parts across devices. Your data is private and only accessible to you.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: scheme.onSurface.withValues(alpha: 0.7),
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 36),

                    // Email
                    TextFormField(
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      autocorrect: false,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Email is required.';
                        if (!v.contains('@')) return 'Enter a valid email.';
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),

                    // Password
                    TextFormField(
                      controller: _passwordCtrl,
                      obscureText: _obscure,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _submit(),
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                          onPressed: () => setState(() => _obscure = !_obscure),
                        ),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Password is required.';
                        if (!_isLogin && v.length < 6) return 'Password must be at least 6 characters.';
                        return null;
                      },
                    ),
                    // Confirm password (register only)
                    if (!_isLogin) ...[
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _confirmCtrl,
                        obscureText: _obscureConfirm,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _submit(),
                        decoration: InputDecoration(
                          labelText: 'Confirm Password',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(_obscureConfirm ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                            onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                          ),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Please confirm your password.';
                          if (v != _passwordCtrl.text) return 'Passwords do not match.';
                          return null;
                        },
                      ),
                    ],

                    const SizedBox(height: 8),

                    // Forgot password (login only)
                    if (_isLogin)
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: _resetPassword,
                          child: const Text('Forgot password?'),
                        ),
                      ),

                    // Error
                    if (_error != null) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: scheme.error.withValues(alpha:0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _error!,
                          style: TextStyle(color: scheme.error, fontSize: 13),
                        ),
                      ),
                    ],

                    const SizedBox(height: 20),

                    // Submit button
                    FilledButton(
                      onPressed: _loading ? null : _submit,
                      child: _loading
                          ? const SizedBox(
                              height: 20, width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(_isLogin ? 'Sign In' : 'Create Account'),
                    ),
                    const SizedBox(height: 16),

                    // Toggle login / register
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _isLogin ? "Don't have an account?" : 'Already have an account?',
                          style: TextStyle(color: scheme.onSurface.withValues(alpha:0.6)),
                        ),
                        TextButton(
                          onPressed: () => setState(() {
                            _isLogin = !_isLogin;
                            _error = null;
                          }),
                          child: Text(_isLogin ? 'Sign Up' : 'Sign In'),
                        ),
                      ],
                    ),

                    // Skip for now
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        'Skip for now',
                        style: TextStyle(color: scheme.onSurface.withValues(alpha:0.4), fontSize: 13),
                      ),
                    ),

                    // Privacy Policy + Terms
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Wrap(
                        alignment: WrapAlignment.center,
                        children: [
                          Text(
                            'By signing up you agree to our ',
                            style: TextStyle(fontSize: 11, color: scheme.onSurface.withValues(alpha: 0.4)),
                          ),
                          GestureDetector(
                            onTap: () => launchUrl(Uri.parse('https://wrecklog.com.au/privacy/')),
                            child: Text(
                              'Privacy Policy',
                              style: TextStyle(fontSize: 11, color: scheme.primary, decoration: TextDecoration.underline),
                            ),
                          ),
                          Text(
                            ' and ',
                            style: TextStyle(fontSize: 11, color: scheme.onSurface.withValues(alpha: 0.4)),
                          ),
                          GestureDetector(
                            onTap: () => launchUrl(Uri.parse('https://www.apple.com/legal/internet-services/itunes/dev/stdeula/')),
                            child: Text(
                              'Terms of Use',
                              style: TextStyle(fontSize: 11, color: scheme.primary, decoration: TextDecoration.underline),
                            ),
                          ),
                          Text(
                            '.',
                            style: TextStyle(fontSize: 11, color: scheme.onSurface.withValues(alpha: 0.4)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
