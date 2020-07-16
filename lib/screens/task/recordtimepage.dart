import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RecordTimePage extends StatefulWidget {
  RecordTimePage({Key key, this.user, this.task}) : super(key: key);

  final FirebaseUser user;
  final dynamic task;

  @override
  _RecordTimePageState createState() => _RecordTimePageState();
}

class _RecordTimePageState extends State<RecordTimePage> {
  static const duration = const Duration(seconds: 1);

  int secondsPassed = 0;
  bool isActive = false;
  bool newRecording = true; // user is clicking start for the first time

  DateTime recordStart;
  DateTime recordEnd;

  Timer timer;

  void handleTick() {
    if (isActive) {
      setState(() {
        secondsPassed++;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (timer == null) {
      timer = Timer.periodic(duration, (Timer t) {
        handleTick();
      });
    }
    int seconds = secondsPassed % 60;
    int minutes = secondsPassed ~/ 60;
    int hours = secondsPassed ~/ (60 * 60);

    return Scaffold(
      appBar: AppBar(
        title: Text('TaskPie'),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text('Clocked in: $recordStart'),
            Text('Clocked out: $recordEnd'),
            SizedBox(height: 60),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                LabelText(
                  label: 'HRS',
                  value: hours.toString().padLeft(2, '0'),
                ),
                LabelText(
                  label: 'MIN',
                  value: minutes.toString().padLeft(2, '0'),
                ),
                LabelText(
                  label: 'SEC',
                  value: seconds.toString().padLeft(2, '0'),
                ),
              ],
            ),
            SizedBox(height: 60),
            Container(
              width: 200,
              height: 47,
              margin: EdgeInsets.only(top: 30),
              child: RaisedButton(
                color: isActive ? Colors.yellow[400] : Colors.green[400],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Text(isActive ? 'PAUSE' : 'CLOCK IN'),
                onPressed: () {
                  setState(() {
                    isActive = !isActive;
                    if (newRecording) {
                      recordStart = DateTime.now();
                    }
                    newRecording = false;
                  });
                },
              ),
            ),
            Container(
              width: 200,
              height: 47,
              margin: EdgeInsets.only(top: 30),
              child: RaisedButton(
                color: Colors.red[400],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Text('CLOCK OUT'),
                onPressed: () {
                  setState(() {
                    isActive = false;
                    recordEnd =
                        recordStart.add(Duration(seconds: secondsPassed));
                    secondsPassed = 0;
                    newRecording = true;
                  });
                },
              ),
            ),
            Container(
              width: 200,
              height: 47,
              margin: EdgeInsets.only(top: 30),
              child: RaisedButton(
                color: Colors.grey,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Text('RESET'),
                onPressed: () {
                  setState(() {
                    isActive = false;
                    secondsPassed = 0;
                    newRecording = true;
                    recordStart = null;
                    recordEnd = null;
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LabelText extends StatelessWidget {
  LabelText({this.label, this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 5),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        color: Colors.indigo,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text('$value',
              style: TextStyle(
                color: Colors.white,
                fontSize: 55,
                fontWeight: FontWeight.bold,
              )),
          Text('$label',
              style: TextStyle(
                color: Colors.white70,
              )),
        ],
      ),
    );
  }
}
