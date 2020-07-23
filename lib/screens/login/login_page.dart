import 'package:flutter/material.dart';

import 'package:flutter_login/flutter_login.dart';

import 'package:taskpie/services/login/login.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final Color firstColor = Color(0xff5b86e5);
  final Color secondColor = Color(0xff36d1dc);

  void signInWithGoogleCallback() {
    signInWithGoogle().whenComplete(() {
      Navigator.of(context).popUntil((route) => route.isFirst);
    });
  }

  void signInWithEmailCallback() {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return EmailSignIn();
    }));
  }

  final Image googleLogo =
      Image(image: ExactAssetImage("assets/google_logo.png"), height: 30.0);

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
              SignInButton(
                label: 'Sign in with Email   ',
                icon: Icon(
                  Icons.email,
                  color: Colors.white,
                  size: 30,
                ),
                signInCallback: signInWithEmailCallback,
                gradientColors: [firstColor, secondColor],
                borderColor: Colors.indigo,
              ),
              SizedBox(height: 30),
              SignInButton(
                label: 'Sign in with Google',
                icon: googleLogo,
                signInCallback: signInWithGoogleCallback,
                gradientColors: [Colors.indigo, Colors.indigo],
                borderColor: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class EmailSignIn extends StatelessWidget {
  const EmailSignIn({Key key}) : super(key: key);
  Duration get loginTime => Duration(milliseconds: 1000);

  Future<String> _authUserSignIn(LoginData data) {
    return Future.delayed(loginTime).then((_) async {
      var result = await signIn(data.name, data.password);
      if (result != 'success') return result;
      return null;
    });
  }

  Future<String> _authUserSignUp(LoginData data) {
    return Future.delayed(loginTime).then((_) async {
      var result = await signUp(data.name, data.password);
      if (result != 'success') return result;
      return null;
    });
  }

  Future<String> _recoverPassword(String name) {
    return Future.delayed(loginTime).then((_) async {
      var result = await sendPasswordResetEmail(name);
      if (result != 'success') return result;
      return null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FlutterLogin(
      title: '',
      logo: 'assets/apple-pie.png',
      onLogin: _authUserSignIn,
      onSignup: _authUserSignUp,
      onSubmitAnimationCompleted: () {
        Navigator.of(context).popUntil((route) => route.isFirst);
      },
      onRecoverPassword: _recoverPassword,
    );
  }
}

class SignInButton extends StatelessWidget {
  const SignInButton(
      {Key key,
      this.label,
      this.icon,
      this.signInCallback,
      this.gradientColors,
      this.borderColor})
      : super(key: key);

  final String label;
  final dynamic icon;
  final Function signInCallback;
  final List<Color> gradientColors;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60.0,
      child: OutlineButton(
        splashColor: Colors.white,
        onPressed: signInCallback,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
        highlightElevation: 0,
        borderSide: BorderSide(color: borderColor),
        padding: EdgeInsets.all(0),
        child: Ink(
          padding: EdgeInsets.fromLTRB(20, 15, 20, 15),
          decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: gradientColors,
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(30.0)),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              icon,
              Padding(
                padding: const EdgeInsets.only(left: 15),
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
