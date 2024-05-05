import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'SuperAppHome.dart';

class SuperAppLogin extends StatefulWidget {
  @override
  _SuperAppLoginState createState() => _SuperAppLoginState();
}

class _SuperAppLoginState extends State<SuperAppLogin> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _signInWithEmailAndPassword() async {
    try {
      final User? user = (await _auth.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      )).user;

      if (user != null) {
        // On successful login, launch mini-app
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SuperAppHome(user: user)),
        );
      }
    } catch (e) {
      print("Error signing in: $e");
      // Handle errors or notify user
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Super App Login')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            ElevatedButton(
              onPressed: _signInWithEmailAndPassword,
              child: Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}
