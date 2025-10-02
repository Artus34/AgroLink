// lib/features/home/views/admin_home_screen.dart

import 'package:flutter/material.dart';

class AdminHomeScreens extends StatelessWidget {
  const AdminHomeScreens({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        // Optional: Add a logout button to the app bar
        // actions: [
        //   IconButton(
        //     icon: const Icon(Icons.logout),
        //     onPressed: () {
        //       // Implement logout functionality here
        //     },
        //   ),
        // ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Welcome, Admin!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            // This is the new button
            ElevatedButton(
              onPressed: () {
                // ⭐️ Navigate to the user home screen AND pass an argument
                Navigator.pushNamed(
                  context,
                  '/home',
                  arguments: {'isAdminViewing': true}, // This is the flag
                );
              },
              child: const Text('View as User'),
            ),
            // You can add other admin-specific widgets here
          ],
        ),
      ),
    );
  }
}

