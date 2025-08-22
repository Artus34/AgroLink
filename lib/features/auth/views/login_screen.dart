// lib/features/auth/views/login_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../app/theme/app_colors.dart';
import '../controllers/auth_provider.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // Gradient Background
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.0,
            colors: [AppColors.backgroundEnd, AppColors.backgroundStart],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            // Responsive Card
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Container(
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header
                      const Text(
                        'Agrolink',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.primaryGreen,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Welcome! Please login or create an account.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.fontSecondary, fontSize: 14),
                      ),
                      const SizedBox(height: 24),

                      // Tab Selector
                      _buildTabSelector(context),
                      const SizedBox(height: 24),

                      // Form Fields
                      const Text('Email', style: TextStyle(color: AppColors.fontSecondary)),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _emailController,
                        style: const TextStyle(color: AppColors.fontPrimary),
                        decoration: const InputDecoration(hintText: 'name@example.com'),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) => (value == null || !value.contains('@')) ? 'Enter a valid email' : null,
                      ),
                      const SizedBox(height: 16),
                      const Text('Password', style: TextStyle(color: AppColors.fontSecondary)),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _passwordController,
                        style: const TextStyle(color: AppColors.fontPrimary),
                        decoration: const InputDecoration(hintText: '••••••••'),
                        obscureText: true,
                        validator: (value) => (value == null || value.isEmpty) ? 'Enter your password' : null,
                      ),
                      const SizedBox(height: 24),

                      // Error Message
                      Consumer<AuthProvider>(
                        builder: (context, auth, child) {
                          if (auth.errorMessage != null) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Text(
                                auth.errorMessage!,
                                style: const TextStyle(color: Colors.redAccent),
                                textAlign: TextAlign.center,
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),

                      // Login Button
                      Consumer<AuthProvider>(
                        builder: (context, auth, child) {
                          return auth.isLoading
                              ? const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen))
                              : ElevatedButton(
                                  onPressed: () => _loginUser(context),
                                  child: const Text('Login'),
                                );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabSelector(BuildContext context) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.backgroundStart,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.inactiveTab,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Text('Login', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/signup'),
              child: Container(
                color: Colors.transparent,
                child: const Center(
                  child: Text('Sign Up', style: TextStyle(color: AppColors.fontSecondary)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _loginUser(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      final auth = context.read<AuthProvider>();
      bool loggedIn = await auth.login(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
      if (loggedIn && context.mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    }
  }
}