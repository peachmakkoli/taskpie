import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:suncircle/screens/task/taskform.dart';
import 'package:suncircle/screens/task/deletetask.dart';
import 'package:suncircle/screens/task/recordtimepage.dart';

Widget viewTaskModal(context, FirebaseUser user, dynamic data) {
  if (data.id.isEmpty) return null; // prevents placeholders from being tapped

  int durationHour = data.duration.floor();
  int durationMinute = ((data.duration - data.duration.floor()) * 60).floor();

  showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return Container(
          height: MediaQuery.of(context).size.height * .50,
          child: Padding(
            padding: EdgeInsets.fromLTRB(24.0, 16.0, 24.0, 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Text(
                      data.name,
                      style: TextStyle(
                        fontSize: 18.0,
                        color: Colors.indigo,
                      ),
                    ),
                    Spacer(),
                    IconButton(
                      icon: Icon(
                        Icons.close,
                        color: Colors.red,
                        size: 25,
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
                Text('Category: ${data.category}'),
                SizedBox(height: 10),
                Text('Start: ' +
                    DateFormat.yMMMd().add_jm().format(data.timeStart)),
                SizedBox(height: 10),
                Text(
                    'End: ' + DateFormat.yMMMd().add_jm().format(data.timeEnd)),
                SizedBox(height: 10),
                Text('Duration: $durationHour h $durationMinute m'),
                SizedBox(height: 10),
                Text('Notes: ' + _showNotes(data.notes)),
                Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    IconButton(
                      tooltip: 'Record time',
                      icon: Icon(
                        Icons.alarm_add,
                        size: 40,
                        color: Colors.indigo,
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) {
                              return RecordTimePage(user: user, task: data);
                            },
                          ),
                        );
                      },
                    ),
                    IconButton(
                      tooltip: 'Edit task',
                      icon: Icon(
                        Icons.create,
                        size: 40,
                        color: Colors.indigo,
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) {
                              return TaskForm(
                                title: 'TaskPie',
                                subtitle: 'Update Task',
                                user: user,
                                task: TaskModel(
                                    data.category,
                                    data.name,
                                    data.timeStart,
                                    data.timeEnd,
                                    data.notes,
                                    data.id),
                              );
                            },
                          ),
                        );
                      },
                    ),
                    IconButton(
                      tooltip: 'Delete task',
                      icon: Icon(
                        Icons.delete_outline,
                        size: 40,
                        color: Colors.red,
                      ),
                      onPressed: () {
                        showDeleteTaskAlert(bc, data, user);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      });
}

String _showNotes(notes) {
  if (notes != null)
    return notes;
  else
    return '';
}
