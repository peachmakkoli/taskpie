import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';

import 'package:taskpie/screens/login/login_page.dart';
import 'package:taskpie/screens/homepage/home_page.dart';

class LandingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<FirebaseUser>(
      stream: FirebaseAuth.instance.onAuthStateChanged,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          FirebaseUser user = snapshot.data;
          if (user == null) {
            return EmailSignIn();
          }
          return HomePage(title: 'TaskPie', user: user);
        } else {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    );
  }
}
