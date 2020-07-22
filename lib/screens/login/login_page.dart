import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';

import 'package:nice_button/nice_button.dart';
import 'package:flutter_auth_buttons/flutter_auth_buttons.dart';
import 'package:flutter_login/flutter_login.dart';

import 'package:taskpie/components/loading_dialog.dart';
import 'package:taskpie/services/login/login.dart';
import 'package:taskpie/screens/login/landing_page.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final Color firstColor = Color(0xff5b86e5);
  final Color secondColor = Color(0xff36d1dc);

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
              GoogleSignInButton(
                onPressed: signInWithGoogle,
              ),
              NiceButton(
                background: Colors.white,
                radius: 40,
                padding: const EdgeInsets.all(15),
                text: 'Register with email',
                icon: Icons.drafts,
                gradientColors: [secondColor, firstColor],
                onPressed: () {
                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (context) {
                    return EmailSignIn();
                  }));
                },
              ),
              // NiceButton(
              //   background: Colors.white,
              //   radius: 40,
              //   padding: const EdgeInsets.all(15),
              //   text: 'Log in with email',
              //   icon: Icons.email,
              //   gradientColors: [secondColor, firstColor],
              //   onPressed: signIn,
              // ),
              // SignInButtonBuilder(
              //   icon: Icons.phone,
              //   text: 'Sign in with phone',
              //   onPressed: _signInWithPhone,
              //   backgroundColor: Colors.blueGrey[700],
              // )
            ],
          ),
        ),
      ),
    );
  }
}

class EmailSignIn extends StatelessWidget {
  const EmailSignIn({Key key}) : super(key: key);
  Duration get loginTime => Duration(milliseconds: 2250);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List>(
        future: getUsers(),
        builder: (context, snapshot) {
          if (snapshot.hasData) return Text('Loading...');
          List<dynamic> _users = snapshot.data;

          Future<String> _authUser(LoginData data) {
            List<String> _userEmails = List<String>();
            _users.forEach((user) => _userEmails.add(user['email']));
            var _user = _users.firstWhere((user) => user['email'] == data.name);

            print('Name: ${data.name}, Password: ${data.password}');
            return Future.delayed(loginTime).then((_) {
              if (_userEmails.contains(data.name)) {
                return 'User already exists';
              }
              if (_user['password'] != data.password) {
                return 'Password does not match';
              }
              signUp(data.name, data.password);
              return null;
            });
          }

          Future<String> _recoverPassword(String name) {
            List<String> _userEmails = List<String>();
            _users.forEach((user) => _userEmails.add(user['email']));
            print('Name: $name');
            return Future.delayed(loginTime).then((_) {
              if (!_userEmails.contains(name)) {
                return 'User does not exist';
              }
              return null;
            });
          }

          return FlutterLogin(
            title: 'TaskPie',
            logo: 'assets/apple-pie.png',
            onLogin: _authUser,
            onSignup: _authUser,
            onSubmitAnimationCompleted: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
              print('successful login');
            },
            onRecoverPassword: _recoverPassword,
          );
        });
  }
}

// class SignInButton extends StatelessWidget {
//   const SignInButton({Key key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return OutlineButton(
//       splashColor: Colors.white,
//       onPressed: () {
//         LoadingDialog.show(context);
//         signInWithGoogle().whenComplete(() {
//           LoadingDialog.hide(context);
//           Navigator.of(context).popUntil((route) => route.isFirst);
//         });
//       },
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
//       highlightElevation: 0,
//       borderSide: BorderSide(color: Colors.white),
//       child: Padding(
//         padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
//         child: Row(
//           mainAxisSize: MainAxisSize.min,
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             Image(
//                 image: ExactAssetImage("assets/google_logo.png"), height: 35.0),
//             Padding(
//               padding: const EdgeInsets.only(left: 10),
//               child: Text(
//                 'Sign in with Google',
//                 style: TextStyle(
//                   fontSize: 20,
//                   color: Colors.white,
//                 ),
//               ),
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }
