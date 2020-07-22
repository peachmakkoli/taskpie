import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:firebase_auth/firebase_auth.dart';

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

  Text _showTime(String label, DateTime time) {
    return Text('$label: ' + DateFormat.yMMMd().add_jm().format(time));
  }

  Text _showDuration(String label) {
    return Text('$label: $_durationHour h $_durationMinute m');
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
      height: MediaQuery.of(context).size.height * .50,
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
                    fontSize: 18.0,
                    color: Colors.indigo,
                  ),
                ),
                Spacer(),
                IconButton(
                  tooltip: 'Close',
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
            Text('Category: ${task.category}'),
            SizedBox(height: 10),
            showRecordedTime
                ? _showTime('Recorded Start', task.recordStart)
                : _showTime('Start', task.timeStart),
            SizedBox(height: 10),
            showRecordedTime
                ? _showTime('Recorded End', task.recordEnd)
                : _showTime('End', task.timeEnd),
            SizedBox(height: 10),
            showRecordedTime
                ? _showDuration('Duration')
                : _showDuration('Recorded Duration'),
            SizedBox(height: 10),
            Text(task.notes == null ? 'Notes: ' : 'Notes: ${task.notes}'),
            Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                showRecordedTime
                    ? SizedBox(width: 40)
                    : StatefulBuilder(builder:
                        (BuildContext context, StateSetter setButtonState) {
                        return IconButton(
                          tooltip: (task.alertSet != true)
                              ? 'Add alert'
                              : 'Alert is set',
                          icon: Icon(
                            (task.alertSet != true)
                                ? Icons.add_alert
                                : Icons.notifications_off,
                            color: (task.alertSet != true)
                                ? Colors.indigo
                                : Colors.red,
                            size: 40,
                          ),
                          onPressed: (task.alertSet != true)
                              ? () {
                                  setButtonState(() {
                                    task.alertSet = true;
                                  });
                                  saveTask(task, user);
                                  _scheduleNotification();
                                }
                              : () {
                                  setButtonState(() {
                                    task.alertSet = false;
                                  });
                                  saveTask(task, user);
                                  _cancelNotification();
                                },
                        );
                      }),
                IconButton(
                  tooltip: 'Record time',
                  icon: Icon(
                    Icons.timer,
                    size: 40,
                    color: Colors.indigo,
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
                          color: Colors.red,
                        ),
                        onPressed: () {
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
