// lib/features/auth/controllers/auth_provider.dart

import 'package:flutter/material.dart'; // Correct

class AuthProvider with ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Simulates a user login.
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    // Simulate a network call
    await Future.delayed(const Duration(seconds: 1));

    // ** THIS IS THE MODIFIED LINE FOR FLEXIBLE LOGIN **
    if (email.contains('@') && password.isNotEmpty) {
      _isLoading = false;
      notifyListeners();
      return true; // Login successful
    } else {
      _errorMessage = 'Invalid email or password format.';
      _isLoading = false;
      notifyListeners();
      return false; // Login failed
    }
  }

  /// Simulates a new user signup.
  Future<bool> signup(String name, String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    // Simulate a network call to create a user
    await Future.delayed(const Duration(seconds: 2));

    if (name.isNotEmpty && email.contains('@') && password.length >= 6) {
       _isLoading = false;
       notifyListeners();
       return true; // Signup successful
    } else {
      _errorMessage = 'Please fill all fields correctly.';
      _isLoading = false;
      notifyListeners();
      return false; // Signup failed
    }
  }
}