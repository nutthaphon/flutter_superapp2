import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'SuperAppHome.dart'; // Your home screen after successful login.

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
  
  String _fid = 'Unknown';

  @override
  void initState() {
    super.initState();
    _getFID();
  }

  Future<void> _getFID() async {
    String? fid = await FirebaseMessaging.instance.getToken();
    setState(() {
      _fid = fid ?? 'No FID found';
    });
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
            children: <Widget>[
              // Email/Password Login
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
              // Phone Authentication
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
              Divider(),
              // Google Sign-In
              ElevatedButton(
                onPressed: _signInWithGoogle,
                child: Text('Sign in with Google'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  minimumSize: Size(double.infinity, 50),
                ),
              ),
              // Facebook Sign-In Button
              ElevatedButton(
                onPressed: _signInWithFacebook,
                child: Text('Sign in with Facebook'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  minimumSize: Size(double.infinity, 50),
                ),
              ),
              FutureBuilder<String?>(
          future: FirebaseMessaging.instance.getToken(),
          builder: (BuildContext context, AsyncSnapshot<String?> snapshot) {
            // Check if the future is resolved
            if (snapshot.connectionState == ConnectionState.done) {
              // Check if the snapshot has data
              if (snapshot.hasData) {
                // Display the FCM token
                return SelectableText('FCM Token: ${snapshot.data}', textAlign: TextAlign.center);
              } else if (snapshot.hasError) {
                // If there was an error fetching the token, display the error
                return Text('Error fetching FCM token: ${snapshot.error}');
              }
            }
            // By default, show a loading spinner while the token is being fetched
            return CircularProgressIndicator();
          },
        ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _signInWithEmailAndPassword() async {
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
      _showErrorDialog(e.toString());
    }
  }

  Future<void> _verifyPhoneNumber() async {
    await _auth.verifyPhoneNumber(
      phoneNumber: _phoneController.text,
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _auth.signInWithCredential(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        _showErrorDialog(e.toString());
      },
      codeSent: (String verificationId, int? resendToken) {
        setState(() {
          _verificationId = verificationId;
        });
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  Future<void> _signInWithPhoneNumber() async {
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
      _showErrorDialog(e.toString());
    }
  }

  Future<void> _signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );
      final User? user = (await _auth.signInWithCredential(credential)).user;
      if (user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => SuperAppHome(user: user)),
        );
      }
    } catch (e) {
      _showErrorDialog(e.toString());
    }
  }

  Future<void> _signInWithFacebook() async {
    try {
      final LoginResult result = await FacebookAuth.instance.login();
      if (result.status == LoginStatus.success) {
        final AccessToken accessToken = result.accessToken!;
        final OAuthCredential credential = FacebookAuthProvider.credential(accessToken.token);
        final UserCredential userCredential = await _auth.signInWithCredential(credential);
        final User? user = userCredential.user;

        if (user != null) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => SuperAppHome(user: user)),
          );
        }
      } else {
        _showErrorDialog('Facebook login failed: ${result.status}');
      }
    } catch (e) {
      _showErrorDialog('Failed to sign in with Facebook: $e');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Authentication Failed'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            child: Text('Okay'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }
}
