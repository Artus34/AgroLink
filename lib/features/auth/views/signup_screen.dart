import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../app/theme/app_colors.dart';
import '../controllers/auth_provider.dart';

// ⭐️ MODIFICATION 1: Converted to a StatefulWidget to handle state for the role selector.
class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // ⭐️ MODIFICATION 2: Added state variables for the role selection.
  String _selectedRole = 'user'; // Defaults to 'user'
  final List<bool> _isSelected = [true, false]; // [user, farmer]

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

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

                      // ⭐️ MODIFICATION 3: Added the new role selector widget to the form.
                      _buildRoleSelector(),

                      const SizedBox(height: 24),
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

  // ⭐️ MODIFICATION 4: This is the new widget for selecting a role.
  Widget _buildRoleSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text('I am a:', style: TextStyle(color: AppColors.fontSecondary, fontSize: 16)),
        const SizedBox(height: 8),
        ToggleButtons(
          isSelected: _isSelected,
          onPressed: (int index) {
            setState(() {
              for (int i = 0; i < _isSelected.length; i++) {
                _isSelected[i] = i == index;
              }
              _selectedRole = index == 0 ? 'user' : 'farmer';
            });
          },
          borderRadius: BorderRadius.circular(8.0),
          selectedBorderColor: AppColors.primaryGreen,
          selectedColor: Colors.white,
          fillColor: AppColors.primaryGreen,
          color: AppColors.primaryGreen,
          constraints: const BoxConstraints(minHeight: 40.0, minWidth: 100.0),
          children: const [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text('User'),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text('Farmer'),
            ),
          ],
        ),
      ],
    );
  }

  // ⭐️⭐️ THIS IS THE CORRECTED METHOD ⭐️⭐️
  void _signUpUser(BuildContext context) async {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState!.validate()) {
      final auth = context.read<AuthProvider>();
      try {
        // ⭐️ FIX: Switched to named parameters to match the provider's definition.
        await auth.signup(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
          role: _selectedRole,
        );

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: AppColors.primaryGreen,
              content: Text('Account created successfully! Please log in.'),
            ),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        // Error is handled by the provider and displayed by the Consumer.
      }
    }
  }
}

