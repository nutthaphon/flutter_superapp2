import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'SuperAppLogin.dart'; // Make sure to import the login screen
import 'MiniAppLauncher.dart';

class SuperAppHome extends StatelessWidget {
  final User user;
  final GoogleSignIn _googleSignIn = new GoogleSignIn();
  SuperAppHome({required this.user});

  void _signOut(BuildContext context) async {
    await _googleSignIn.signOut(); // Google sign out
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => SuperAppLogin()),
    );
  }

  Future<String?> fetchFID() async {
    // Simulate a network request delay
    String? fid = await FirebaseMessaging.instance.getToken();
    print(fid.toString());
    return fid;
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
            Text('User UID: ${user.uid}!'),
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
