import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> _deleteTask(task, user) async {
  final CollectionReference usersRef = Firestore.instance.collection('users');
  final snapShot = await usersRef.document(user.uid).get();

  if (snapShot.exists) {
    await usersRef
        .document(user.uid)
        .collection('tasks')
        .document(task.id)
        .delete();
  }
}

Future<void> showDeleteTaskAlert(context, task, user) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('${task.name}',
            style: GoogleFonts.chelaOne(textStyle: TextStyle(fontSize: 26.0))),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text(
                  'Are you sure you want to delete this task? This action is not reversible.'),
            ],
          ),
        ),
        actions: <Widget>[
          FlatButton(
            child: Text('No'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          FlatButton(
            child: Text('Yes'),
            onPressed: () {
              _deleteTask(task, user)
                  .whenComplete(() => Navigator.of(context).pop());
            },
          ),
        ],
      );
    },
  );
}
