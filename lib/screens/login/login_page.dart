import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:flutter_login/flutter_login.dart';

import 'package:taskpie/services/login/login.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final Color firstColor = Color(0xFFF46262);
  final Color secondColor = Color(0xFF3175B8);

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
        color: Color(0xFF3F88C5),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image(
                  image: ExactAssetImage('assets/apple-pie.png'),
                  height: 230.0),
              Text(
                'TaskPie',
                style: GoogleFonts.chelaOne(
                  textStyle: TextStyle(
                    fontSize: 80,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(height: 30),
              SignInButton(
                label: 'Sign in with Email   ',
                icon: Icon(
                  Icons.email,
                  color: Colors.white,
                  size: 30,
                ),
                signInCallback: signInWithEmailCallback,
                gradientColors: [firstColor, secondColor],
                borderColor: Color(0xFF3F88C5),
                textColor: Colors.white,
              ),
              SizedBox(height: 30),
              SignInButton(
                label: 'Sign in with Google',
                icon: googleLogo,
                signInCallback: signInWithGoogleCallback,
                gradientColors: [Colors.white, Colors.white],
                borderColor: Color(0xFF3F88C5),
                textColor: Color(0xFF3F88C5),
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
    return Scaffold(
      appBar: AppBar(
        title: Text('TaskPie',
            style: GoogleFonts.chelaOne(textStyle: TextStyle(fontSize: 26.0))),
      ),
      body: FlutterLogin(
        title: null,
        logo: 'assets/apple-pie.png',
        onLogin: _authUserSignIn,
        onSignup: _authUserSignUp,
        onSubmitAnimationCompleted: () {
          Navigator.of(context).popUntil((route) => route.isFirst);
        },
        onRecoverPassword: _recoverPassword,
      ),
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
      this.borderColor,
      this.textColor})
      : super(key: key);

  final String label;
  final dynamic icon;
  final Function signInCallback;
  final List<Color> gradientColors;
  final Color borderColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60.0,
      child: OutlineButton(
        splashColor: textColor,
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
                    color: textColor,
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
