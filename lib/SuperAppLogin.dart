import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'SuperAppHome.dart'; // Ensure you have this screen for navigation after login

class SuperAppLogin extends StatefulWidget {
  @override
  _SuperAppLoginState createState() => _SuperAppLoginState();
}

class _SuperAppLoginState extends State<SuperAppLogin> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _smsController = TextEditingController();
  String? _verificationId;

  void _signInWithEmailAndPassword() async {
    try {
      final User? user = (await _auth.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      )).user;

      if (user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => SuperAppHome(user: user)),
        );
      }
    } catch (e) {
      print("Error signing in with email/password: $e");
      // Handle errors or notify user
    }
  }

  void _verifyPhoneNumber() async {
    await _auth.verifyPhoneNumber(
      phoneNumber: _phoneController.text,
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _auth.signInWithCredential(credential);
        // This callback gets called when verification is done automatically
      },
      verificationFailed: (FirebaseAuthException e) {
        print("Error verifying phone number: $e");
        // Handle errors or notify user
      },
      codeSent: (String verificationId, int? resendToken) {
        setState(() {
          _verificationId = verificationId;
        });
        // Update UI to show code input box
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        _verificationId = verificationId;
      },
    );
  }

  void _signInWithPhoneNumber() async {
    try {
      final AuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: _smsController.text,
      );

      final User? user = (await _auth.signInWithCredential(credential)).user;

      if (user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => SuperAppHome(user: user)),
        );
      }
    } catch (e) {
      print("Error signing in with phone number: $e");
      // Handle errors or notify user
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Super App Login')),
      body: SingleChildScrollView(
        child: Padding(
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
                child: Text('Login with Email'),
              ),
              Divider(),
              TextField(
                controller: _phoneController,
                decoration: InputDecoration(labelText: 'Phone Number'),
              ),
              ElevatedButton(
                onPressed: _verifyPhoneNumber,
                child: Text('Verify Phone Number'),
              ),
              TextField(
                controller: _smsController,
                decoration: InputDecoration(labelText: 'SMS Code'),
              ),
              ElevatedButton(
                onPressed: _signInWithPhoneNumber,
                child: Text('Login with SMS Code'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
