import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:suncircle/screens/landingpage/landingpage.dart';

class HomePage extends StatelessWidget {

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
        title: Text('suncircle'),
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
          stream: Firestore.instance.collection('users').snapshots(),
          builder: (context, snapshot) {
            if(!snapshot.hasData) return Text('Loading data...');
            return Column(
              children: <Widget>[
                Text(snapshot.data.documents[0]['username']),
                Text(snapshot.data.documents[0]['name']),
                Text(snapshot.data.documents[0]['email'])
              ], // <Widget>
            ); // Column
          },
        ), // Streambuilder
      ), // Center
    ); // Scaffold
  }
}
