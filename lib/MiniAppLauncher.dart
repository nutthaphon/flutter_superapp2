import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

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
        child: Column(
          children: [
            Text('E-Mail: ${user.email}'),
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
    );
  }
}
