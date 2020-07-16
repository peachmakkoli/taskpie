import 'package:flutter/material.dart';
import 'package:flutter_timer/flutter_timer.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StopwatchPage extends StatelessWidget {
  StopwatchPage({Key key, this.user, this.task}) : super(key: key);

  final FirebaseUser user;
  final dynamic task;

  @override
  _StopwatchPageState createState() => _StopwatchPageState();
}

class _StopwatchPageState extends State<StopwatchPage> {
  bool running = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('TaskPie'),
        bottom: 
      ),
    );
  }
}
