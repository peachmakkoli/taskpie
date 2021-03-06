import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:one_context/one_context.dart';

import 'package:taskpie/models/task_model.dart';
import 'package:taskpie/screens/task/record_time_page.dart';
import 'package:taskpie/screens/task/task_form.dart';
import 'package:taskpie/services/task/delete_task.dart';
import 'package:taskpie/services/task/save_task.dart';

class TaskDetailsModal extends StatelessWidget {
  TaskDetailsModal(
      {Key key,
      this.user,
      this.task,
      this.showRecordedTime,
      this.notificationCallback})
      : _durationHour = task.duration.floor(),
        _durationMinute =
            ((task.duration - task.duration.floor()) * 60).floor(),
        super(key: key);

  final FirebaseUser user;
  final TaskModel task;
  final bool showRecordedTime;
  final Function(String, String, DateTime, DateTime, [bool])
      notificationCallback;
  final int _durationHour;
  final int _durationMinute;

  Text _showTime(DateTime time) {
    return Text(DateFormat.yMMMd().add_jm().format(time));
  }

  void _scheduleNotification() async {
    await notificationCallback(
        task.name, task.id, task.timeStart, task.timeEnd);
  }

  void _cancelNotification() async {
    await notificationCallback(
        task.name, task.id, task.timeStart, task.timeEnd, true);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * .60,
      child: Padding(
        padding: EdgeInsets.fromLTRB(24.0, 16.0, 24.0, 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Text(
                  task.name,
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3F88C5),
                  ),
                ),
                Spacer(),
                IconButton(
                  tooltip: 'Close',
                  icon: Icon(
                    Icons.close,
                    color: Color(0xFFF46262),
                    size: 25,
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
            SizedBox(width: 10),
            Row(
              children: <Widget>[
                Container(
                  constraints: BoxConstraints(minWidth: 85),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    color: task.color,
                  ),
                  padding: const EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 4.0),
                  margin: EdgeInsets.only(top: 5),
                  child: Align(
                    alignment: Alignment.center,
                    child: Text('Category',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        )),
                  ),
                ),
                SizedBox(width: 10),
                Text(task.category),
              ],
            ),
            SizedBox(height: 10),
            Row(
              children: <Widget>[
                Container(
                  constraints: BoxConstraints(minWidth: 85),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    color: Colors.green[400],
                  ),
                  padding: const EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 4.0),
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(showRecordedTime ? 'Recorded Start' : 'Start',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        )),
                  ),
                ),
                SizedBox(width: 10),
                showRecordedTime
                    ? _showTime(task.recordStart)
                    : _showTime(task.timeStart),
              ],
            ),
            SizedBox(height: 10),
            Row(
              children: <Widget>[
                Container(
                  constraints: BoxConstraints(minWidth: 85),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    color: Colors.red[400],
                  ),
                  padding: const EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 4.0),
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(showRecordedTime ? 'Recorded End' : 'End',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        )),
                  ),
                ),
                SizedBox(width: 10),
                showRecordedTime
                    ? _showTime(task.recordEnd)
                    : _showTime(task.timeEnd),
              ],
            ),
            SizedBox(height: 10),
            Row(
              children: <Widget>[
                Container(
                  constraints: BoxConstraints(minWidth: 85),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    color: Color(0xFF3F88C5),
                  ),
                  padding: const EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 4.0),
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(
                        showRecordedTime ? 'Recorded Duration' : 'Duration',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        )),
                  ),
                ),
                SizedBox(width: 10),
                Text('$_durationHour h $_durationMinute m'),
              ],
            ),
            SizedBox(height: 10),
            Wrap(
              children: <Widget>[
                Container(
                  constraints: BoxConstraints(minWidth: 85),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    color: Color(0xFF3F88C5),
                  ),
                  padding: const EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 4.0),
                  margin: EdgeInsets.only(bottom: 5),
                  child: Align(
                    alignment: Alignment.center,
                    child: Text('Notes',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        )),
                  ),
                ),
                Text(task.notes == null ? '' : task.notes),
              ],
            ),
            Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                showRecordedTime
                    ? SizedBox(width: 40)
                    : StatefulBuilder(builder:
                        (BuildContext context, StateSetter setButtonState) {
                        return IconButton(
                          color: Colors.black,
                          tooltip: (task.alertSet != true)
                              ? 'Add alert'
                              : 'Alert is set',
                          icon: Icon(
                            (task.alertSet != true)
                                ? Icons.add_alert
                                : Icons.notifications_off,
                            color: (task.alertSet != true)
                                ? Color(0xFF3F88C5)
                                : Color(0xFFF46262),
                            size: 40,
                          ),
                          onPressed: (task.alertSet != true)
                              ? () {
                                  setButtonState(() {
                                    task.alertSet = true;
                                  });
                                  saveTask(task, user);
                                  _scheduleNotification();
                                  OneContext().showSnackBar(
                                      builder: (_) => SnackBar(
                                          content: Text(
                                              'Reminders set for ${task.name}')));
                                }
                              : () {
                                  setButtonState(() {
                                    task.alertSet = false;
                                  });
                                  saveTask(task, user);
                                  _cancelNotification();
                                  OneContext().showSnackBar(
                                      builder: (_) => SnackBar(
                                          content: Text(
                                              'Reminders cancelled for ${task.name}')));
                                },
                        );
                      }),
                IconButton(
                  tooltip: 'Record time',
                  icon: Icon(
                    Icons.timer,
                    size: 40,
                    color: Color(0xFF3F88C5),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) {
                          return RecordTimePage(user: user, task: task);
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
                    color: Color(0xFF3F88C5),
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
                            task: task,
                            showRecordedTime: showRecordedTime,
                          );
                        },
                      ),
                    );
                  },
                ),
                showRecordedTime
                    ? SizedBox(width: 40)
                    : IconButton(
                        tooltip: 'Delete task',
                        icon: Icon(
                          Icons.delete_outline,
                          size: 40,
                          color: Color(0xFFF46262),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                          showDeleteTaskAlert(context, task, user);
                        },
                      ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
