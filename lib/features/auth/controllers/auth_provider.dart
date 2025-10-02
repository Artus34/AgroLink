import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/models/user_model.dart'; // ⭐️ IMPORT THE USER MODEL

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ⭐️ STATE MANAGEMENT PROPERTIES ⭐️
  UserModel? _userModel;
  bool _isLoading = false;
  String? _errorMessage;

  // ⭐️ PUBLIC GETTERS ⭐️
  UserModel? get userModel => _userModel;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Constructor: Listens to authentication state changes right away.
  AuthProvider() {
    _auth.authStateChanges().listen(_onAuthStateChanged);
  }

  /// Private method to handle what happens when a user logs in or out.
  Future<void> _onAuthStateChanged(User? firebaseUser) async {
    if (firebaseUser == null) {
      _userModel = null; // User is logged out
    } else {
      await _fetchUser(firebaseUser.uid); // User is logged in, fetch their data
    }
    notifyListeners();
  }

  /// Fetches the user's data from Firestore and stores it in the provider.
  Future<void> _fetchUser(String uid) async {
    try {
      final docSnapshot = await _firestore.collection('users').doc(uid).get();
      if (docSnapshot.exists) {
        _userModel = UserModel.fromMap(docSnapshot.data()!);
      }
    } catch (e) {
      _errorMessage = "Error fetching user data.";
      print("Error fetching user: $e");
    }
    notifyListeners();
  }

  // ⭐️⭐️ THIS IS THE CORRECTED METHOD ⭐️⭐️
  /// Logs in a user. The auth state listener will handle fetching data.
  /// Returns `true` on success, `false` on failure.
  Future<bool> login({required String email, required String password}) async {
    _setLoading(true);
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      _setLoading(false);
      return true; // Return success
    } on FirebaseAuthException catch (e) {
      _setError(e.message);
      _setLoading(false);
      return false; // Return failure
    } catch (e) {
      _setError('An unknown error occurred.');
      _setLoading(false);
      return false; // Return failure
    }
  }

  /// ⭐️ SIGNUP METHOD UPDATED TO ACCEPT ROLE ⭐️
  /// Creates a new user and saves their profile with a specific role.
  Future<void> signup(
      {required String name, required String email, required String password, required String role}) async {
    _setLoading(true);
    try {
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      final User? user = userCredential.user;
      if (user != null) {
        // Use the UserModel to create a structured user object
        final newUser = UserModel(
          uid: user.uid,
          name: name,
          email: email,
          role: role, // Use the role passed from the signup screen
        );
        // Save the structured data to Firestore
        await _firestore.collection('users').doc(user.uid).set(newUser.toMap());
      }
    } on FirebaseAuthException catch (e) {
      _setError(e.message);
      throw e; // Re-throw to be caught by the UI
    } catch (e) {
      _setError('An unknown error occurred.');
      throw e;
    } finally {
      _setLoading(false);
    }
  }

  /// ⭐️ NEW METHOD TO UPDATE USER'S NAME ⭐️
  Future<bool> updateUserName(String newName) async {
    if (_userModel == null) return false;
    _setLoading(true);
    try {
      // Create an updated user model using the copyWith helper
      final updatedUser = _userModel!.copyWith(name: newName);

      // Update the document in Firestore
      await _firestore.collection('users').doc(_userModel!.uid).update(updatedUser.toMap());

      // Update the local state to instantly reflect the change in the UI
      _userModel = updatedUser;
      
      return true; // Return success
    } catch (e) {
      _setError('Failed to update profile.');
      print("Error updating user name: $e");
      return false; // Return failure
    } finally {
      _setLoading(false);
    }
  }

  /// Signs the user out. The auth state listener will clear the user data.
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Helper methods to reduce boilerplate
  void _setLoading(bool loading) {
    _isLoading = loading;
    if (loading) _errorMessage = null; // Clear previous errors when a new action starts
    notifyListeners();
  }

  void _setError(String? message) {
    _errorMessage = message ?? 'An unknown error occurred.';
    notifyListeners();
  }
}

