// lib/features/auth/views/signup_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../app/theme/app_colors.dart';
import '../controllers/auth_provider.dart';

class SignUpScreen extends StatelessWidget {
  SignUpScreen({super.key});

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
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
                      const Text(
                        'Create Account',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.primaryGreen,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Get started with Agrolink.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.fontSecondary, fontSize: 14),
                      ),
                      const SizedBox(height: 24),
                      _buildTabSelector(context),
                      const SizedBox(height: 24),
                      const Text('Full Name', style: TextStyle(color: AppColors.fontSecondary)),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(hintText: 'John Appleseed'),
                        validator: (value) => (value == null || value.isEmpty) ? 'Enter your name' : null,
                      ),
                      const SizedBox(height: 16),
                      const Text('Email', style: TextStyle(color: AppColors.fontSecondary)),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(hintText: 'name@example.com'),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) => (value == null || !value.contains('@')) ? 'Enter a valid email' : null,
                      ),
                      const SizedBox(height: 16),
                      const Text('Password', style: TextStyle(color: AppColors.fontSecondary)),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _passwordController,
                        decoration: const InputDecoration(hintText: 'Min. 6 characters'),
                        obscureText: true,
                        validator: (value) => (value == null || value.length < 6) ? 'Password is too short' : null,
                      ),
                      const SizedBox(height: 24),
                      Consumer<AuthProvider>(
                        builder: (context, auth, child) {
                          return auth.isLoading
                              ? const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen))
                              : ElevatedButton(
                                  onPressed: () => _signUpUser(context),
                                  child: const Text('Sign Up'),
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
            child: GestureDetector(
              onTap: () => Navigator.pop(context), // Go back to login
              child: Container(
                color: Colors.transparent,
                child: const Center(
                  child: Text('Login', style: TextStyle(color: AppColors.fontSecondary)),
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.inactiveTab,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Text('Sign Up', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _signUpUser(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      final auth = context.read<AuthProvider>();
      bool signedUp = await auth.signup(
        _nameController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
      if (signedUp && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: AppColors.primaryGreen,
            content: Text('Account created successfully! Please log in.'),
          ),
        );
        Navigator.pop(context);
      }
    }
  }
}