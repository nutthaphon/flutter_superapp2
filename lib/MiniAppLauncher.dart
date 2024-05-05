import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MiniAppLauncher extends StatelessWidget {
  final User user;

  MiniAppLauncher({required this.user});

  void _getIdToken() async {
    String? token = await user.getIdToken();
    // In a real scenario, you'd pass this token to your mini-app.
    // For this example, we'll just print it.
    print("Firebase Auth Token: $token");
  }

  @override
  Widget build(BuildContext context) {
    _getIdToken(); // Get and print the token for demonstration.

    return Scaffold(
      appBar: AppBar(title: Text('Mini App')),
      body: Center(
        child: Text('Welcome to the Mini App, ${user.email}'),
      ),
    );
  }
}
