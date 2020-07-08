import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:suncircle/screens/landingpage/landingpage.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key, this.title, this.user}) : super(key: key);

  final String title;
  final FirebaseUser user;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  
  // TODO: Check if a new event has been added so the app can re-render 
  // the calendar circle

  // int _counter = 0;

  // void _incrementCounter() {
  //   setState(() {
  //     // This call to setState tells the Flutter framework that something has
  //     // changed in this State, which causes it to rerun the build method below
  //     // so that the display can reflect the updated values. If we changed
  //     // _counter without calling setState(), then the build method would not be
  //     // called again, and so nothing would appear to happen.
  //     _counter++;
  //   });
  // }

  Future<void> signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
    } catch (error) {
      print(error); // TODO: show dialog with error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        automaticallyImplyLeading: false,
        actions: <Widget>[
          FlatButton(
            child: Text(
              'Logout',
              style: TextStyle(
                fontSize: 18.0,
                color: Colors.white,
              ),
            ),
            onPressed: () {
              signOut().whenComplete(() {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) {
                      return LandingPage();
                    },
                  ),
                );
              });
            },
          ),
        ],
      ),
      body: Center(
        child: StreamBuilder(
          stream: Firestore.instance
            .collection('users')
            .document(widget.user.uid)
            .snapshots(),
          builder: (context, snapshot) {
            if(!snapshot.hasData) return Text('Loading data...');
            return Column(
              children: <Widget>[
                Text(snapshot.data['uid']),
                Text(snapshot.data['name']),
                Text(snapshot.data['email']),
              ], // <Widget>
            ); // Column
          },
        ), // Streambuilder
      ), // Center
    ); // Scaffold
  }
}
