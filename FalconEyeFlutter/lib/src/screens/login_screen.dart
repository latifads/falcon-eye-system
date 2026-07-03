import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/falcon_widgets.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({required this.onLogin, super.key});

  final VoidCallback onLogin;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _showPassword = false;
  String? _error;

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.asset('assets/falcon_logo.png', height: 140),
              const SizedBox(height: 24),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: FalconCard(
                  child: Column(
                    children: <Widget>[
                      const Text(
                        'Welcome Back',
                        style: TextStyle(fontSize: 24, color: AppColors.cyanSoft),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Desert Search & Rescue Command Center',
                        style: TextStyle(color: AppColors.textMuted, fontSize: 15),
                      ),
                      const SizedBox(height: 28),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text('Username', style: TextStyle(fontSize: 16)),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _usernameController,
                        decoration: const InputDecoration(hintText: 'Enter your username'),
                        onChanged: (_) => setState(() => _error = null),
                      ),
                      const SizedBox(height: 20),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text('Password', style: TextStyle(fontSize: 16)),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _passwordController,
                        obscureText: !_showPassword,
                        decoration: InputDecoration(
                          hintText: 'Enter your password',
                          suffixIcon: IconButton(
                            onPressed: () => setState(() => _showPassword = !_showPassword),
                            icon: Icon(
                              _showPassword ? Icons.visibility_off : Icons.visibility,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                        onChanged: (_) => setState(() => _error = null),
                      ),
                      if (_error != null) ...<Widget>[
                        const SizedBox(height: 16),
                        FalconPanel(
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(_error!, style: const TextStyle(color: AppColors.redError)),
                          ),
                        ),
                      ],
                      const SizedBox(height: 20),
                      PrimaryButton(label: 'Log In', onPressed: _submit),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 26),
              const Text(
                'FalconEye v2.0 | Secure Authentication System\n(c) 2024 Desert Search & Rescue Operations',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textMuted, fontSize: 13),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submit() {
    if (_usernameController.text.trim() == 'admin' && _passwordController.text.trim() == 'admin') {
      widget.onLogin();
    } else {
      setState(() => _error = 'Username and password must both be admin.');
    }
  }
}
