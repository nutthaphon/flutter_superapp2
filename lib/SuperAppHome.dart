import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'SuperAppLogin.dart'; // Make sure to import the login screen
import 'MiniAppLauncher.dart';

class SuperAppHome extends StatelessWidget {
  final User user;

  SuperAppHome({required this.user});

  void _signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => SuperAppLogin()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Super App Home'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => _signOut(context),
            tooltip: 'Sign Out',
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Welcome, ${user.uid}!'),
            SizedBox(height: 20),
            ElevatedButton(
              child: Text('Go to Mini App'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MiniAppLauncher(user: user)),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
