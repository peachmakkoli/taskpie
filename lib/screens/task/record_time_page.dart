import 'package:flutter/material.dart';
import 'dart:async';
import 'package:intl/intl.dart';

import 'package:firebase_auth/firebase_auth.dart';

import 'package:taskpie/components/loading_dialog.dart';
import 'package:taskpie/components/submit_form_button.dart';
import 'package:taskpie/services/task/save_task.dart';

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

  Future submitForm() async {
    LoadingDialog.show(context);

    saveRecording(
      widget.task.id,
      recordStart,
      recordEnd,
      widget.user,
    ).whenComplete(() {
      LoadingDialog.hide(context);
      Navigator.of(context).pop();
    });
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
      appBar: AppBar(title: Text('TaskPie: Record Time')),
      floatingActionButton: submitFormButton(context, submitForm),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              'Task: ${widget.task.name}',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 10),
            Text(
              recordStart != null
                  ? 'Clock In: ${DateFormat.yMMMd().add_jm().format(recordStart)}'
                  : 'Clock In: ',
              style: TextStyle(fontSize: 15),
            ),
            Text(
                recordEnd != null
                    ? 'Clock Out: ${DateFormat.yMMMd().add_jm().format(recordEnd)}'
                    : 'Clock Out: ',
                style: TextStyle(fontSize: 15)),
            SizedBox(height: 30),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: 60,
                  height: 60,
                  margin: EdgeInsets.only(top: 30),
                  child: RaisedButton(
                    color: isActive ? Colors.yellow[400] : Colors.green[400],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Icon(isActive ? Icons.pause : Icons.play_arrow,
                        size: 30),
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
                SizedBox(width: 30),
                Container(
                  width: 60,
                  height: 60,
                  margin: EdgeInsets.only(top: 30),
                  child: RaisedButton(
                    color: Colors.red[400],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Icon(Icons.stop, size: 30),
                    onPressed: () {
                      setState(() {
                        isActive = false;
                        recordEnd =
                            recordStart.add(Duration(seconds: secondsPassed));
                        newRecording = true;
                      });
                    },
                  ),
                ),
              ],
            ),
            Container(
              width: 150,
              height: 60,
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
            SizedBox(height: 60),
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
      padding: EdgeInsets.all(15),
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
                fontSize: 48,
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
