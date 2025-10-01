// lib/features/auth/controllers/auth_provider.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Logs in a user with email and password, then fetches their role.
  /// Returns the user's role as a String on success, or null on failure.
  Future<String?> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 1. Authenticate with Firebase Auth
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final User? user = userCredential.user;

      if (user != null) {
        // 2. Fetch user profile from Firestore
        final DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();
        
        if (userDoc.exists) {
          // 3. Return the role
          final userData = userDoc.data() as Map<String, dynamic>;
          return userData['role'] as String?;
        } else {
          // This case is unlikely if signup is correct, but good to handle.
          _errorMessage = 'User profile not found.';
          return null;
        }
      }
      return null;
    } on FirebaseAuthException catch (e) {
      // Handle authentication errors
      _errorMessage = e.message ?? 'An unknown error occurred.';
      return null;
    } catch (e) {
      // Handle other errors (e.g., network)
      _errorMessage = 'An error occurred. Please try again.';
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Creates a new user account and saves their profile to Firestore.
  /// Throws an exception on failure.
  Future<void> signup(String name, String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 1. Create user in Firebase Auth
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final User? user = userCredential.user;

      if (user != null) {
        // 2. Create user profile document in Firestore
        await _firestore.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'name': name,
          'email': email,
          'role': 'user', // Assign a default role
          'createdAt': Timestamp.now(),
        });
      }
    } on FirebaseAuthException catch (e) {
      _errorMessage = e.message ?? 'An unknown error occurred.';
      // Re-throw the exception so the UI can catch it
      throw e;
    } catch (e) {
      _errorMessage = 'An error occurred. Please try again.';
      throw e;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}