// lib/features/auth/views/profile_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/auth_provider.dart';
import 'edit_profile_screen.dart'; // Import the edit screen

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Use a Consumer widget to listen for changes in the AuthProvider.
    // This ensures that when the user's name is updated, this screen will automatically rebuild.
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.userModel;

        return Scaffold(
          appBar: AppBar(
            title: const Text('My Profile'),
            actions: [
              // Edit Profile Button
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  // Only allow editing if a user is logged in.
                  if (user != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const EditProfileScreen(),
                      ),
                    );
                  }
                },
                tooltip: 'Edit Profile',
              ),
            ],
          ),
          body: authProvider.isLoading && user == null
              ? const Center(child: CircularProgressIndicator())
              : user == null
                  ? const Center(child: Text('Please log in to view your profile.'))
                  : Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildProfileHeader(user.name, user.email, user.role),
                          const SizedBox(height: 32),
                          // You can add more profile information list tiles here in the future.
                          const Spacer(), // Pushes the logout button to the bottom
                          ElevatedButton(
                            onPressed: () {
                              authProvider.signOut();
                              // Pop all screens until we get back to the very first screen.
                              Navigator.of(context).popUntil((route) => route.isFirst);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: const Text('Logout', style: TextStyle(fontSize: 16, color: Colors.white)),
                          ),
                        ],
                      ),
                    ),
        );
      },
    );
  }

  /// A helper widget to build the top section of the profile screen.
  Widget _buildProfileHeader(String name, String email, String role) {
    return Column(
      children: [
        const CircleAvatar(
          radius: 50,
          backgroundColor: Colors.green,
          child: Icon(Icons.person, size: 50, color: Colors.white),
        ),
        const SizedBox(height: 16),
        Text(
          name,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          email,
          style: const TextStyle(fontSize: 16, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Chip(
          label: Text(
            role.toUpperCase(),
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          backgroundColor: role == 'farmer' ? Colors.green.shade100 : Colors.blue.shade100,
          padding: const EdgeInsets.symmetric(horizontal: 12),
        ),
      ],
    );
  }
}

