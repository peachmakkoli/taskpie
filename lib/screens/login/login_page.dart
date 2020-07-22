import 'package:flutter/material.dart';

import 'package:taskpie/components/loading_dialog.dart';
import 'package:taskpie/services/login/login.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.indigo,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'TaskPie',
                style: TextStyle(
                  fontSize: 48,
                  color: Colors.white,
                ),
              ),
              Image(
                  image: ExactAssetImage('assets/apple-pie.png'),
                  height: 300.0),
              SizedBox(height: 50),
              SignInButton(),
            ],
          ),
        ),
      ),
    );
  }
}

class SignInButton extends StatelessWidget {
  const SignInButton({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OutlineButton(
      splashColor: Colors.white,
      onPressed: () {
        // LoadingDialog.show(context);
        signInWithGoogle().whenComplete(() {
          // LoadingDialog.hide(context);
          Navigator.of(context).popUntil((route) => route.isFirst);
        });
      },
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
      highlightElevation: 0,
      borderSide: BorderSide(color: Colors.white),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image(
                image: ExactAssetImage("assets/google_logo.png"), height: 35.0),
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Text(
                'Sign in with Google',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
