import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:syncfusion_flutter_charts/charts.dart';

import 'package:suncircle/models/task_model.dart';
import 'package:suncircle/screens/task/task_details_modal.dart';

class CircleCalendar extends StatelessWidget {
  CircleCalendar(
      {Key key,
      this.user,
      this.selectedDate,
      this.nextDay,
      this.showRecordedTime,
      this.notificationCallback})
      : _fieldStart = showRecordedTime ? 'record_start' : 'time_start',
        _fieldEnd = showRecordedTime ? 'record_end' : 'time_end',
        super(key: key);

  final FirebaseUser user;
  final DateTime selectedDate;
  final DateTime nextDay;
  final bool showRecordedTime;
  final Function(String, String, DateTime, DateTime, [bool])
      notificationCallback;
  final String _fieldStart;
  final String _fieldEnd;

  List<TaskModel> _getChartData(categories, tasks) {
    List<TaskModel> _chartData = List<TaskModel>();
    // add white space between start of day and start of first task
    _chartData.add(TaskModel(
      'free time',
      '',
      DateTime.now(),
      DateTime.now(),
      '',
      '',
      TaskModel.getDuration(
          tasks[0][_fieldStart], Timestamp.fromDate(selectedDate)),
      Colors.white,
    ));

    for (var i = 0; i < tasks.length; i++) {
      var category = categories.firstWhere(
        (category) => category.reference.path == tasks[i]['category'].path,
      );

      var _task = TaskModel(
        category.documentID,
        tasks[i]['name'],
        tasks[i]['time_start'].toDate(),
        tasks[i]['time_end'].toDate(),
        tasks[i]['notes'],
        tasks[i].documentID,
        TaskModel.getDuration(tasks[i][_fieldEnd], tasks[i][_fieldStart]),
        TaskModel.getColor(category),
      );

      _task.alertSet =
          tasks[i]['alert_set'] != null ? tasks[i]['alert_set'] : false;
      if (tasks[i]['record_start'] != null)
        _task.recordStart = tasks[i]['record_start'].toDate();
      if (tasks[i]['record_end'] != null)
        _task.recordEnd = tasks[i]['record_end'].toDate();

      _chartData.add(_task);

      // add white space between tasks
      if (i < tasks.length - 1) {
        _chartData.add(TaskModel(
            'free time',
            '',
            DateTime.now(),
            DateTime.now(),
            '',
            '',
            TaskModel.getDuration(
                tasks[i + 1][_fieldStart], tasks[i][_fieldEnd]),
            Colors.white));
      }
    }

    // add white space between end of last task and end of day
    _chartData.add(TaskModel(
        'free time',
        '',
        DateTime.now(),
        DateTime.now(),
        '',
        '',
        TaskModel.getDuration(
            Timestamp.fromDate(selectedDate.add(Duration(days: 1))),
            tasks[tasks.length - 1][_fieldEnd]),
        Colors.white));

    return _chartData;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: Firestore.instance
            .collection('users')
            .document(user.uid)
            .collection('categories')
            .snapshots(),
        builder: (context, categoriesSnapshot) {
          return StreamBuilder(
            stream: Firestore.instance
                .collection('users')
                .document(user.uid)
                .collection('tasks')
                .orderBy(_fieldStart)
                .where(_fieldStart, isGreaterThanOrEqualTo: selectedDate)
                .where(_fieldStart, isLessThan: nextDay)
                .snapshots(),
            builder: (context, tasksSnapshot) {
              if (!categoriesSnapshot.hasData || !tasksSnapshot.hasData)
                return Container(
                    height: MediaQuery.of(context).size.height,
                    alignment: Alignment(0.0, 0.0),
                    child: Text('Loading...'));
              if (tasksSnapshot.data.documents.isEmpty)
                return Container(
                    height: MediaQuery.of(context).size.height,
                    alignment: Alignment(0.0, 0.0),
                    child: Text('No tasks found for selected day.'));
              return Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: ExactAssetImage("assets/clock-face.png"),
                    fit: BoxFit.contain,
                  ),
                ),
                height: MediaQuery.of(context).size.height / 1.2,
                alignment: Alignment(0.0, 0.0),
                child: SfCircularChart(
                  tooltipBehavior: TooltipBehavior(
                      enable: true,
                      activationMode: ActivationMode.longPress,
                      builder: (dynamic data, dynamic point, dynamic series,
                          int pointIndex, int seriesIndex) {
                        if (data.id.isEmpty)
                          return null; // prevents placeholders from being tapped
                        showModalBottomSheet(
                            context: context,
                            builder: (BuildContext context) {
                              return TaskDetailsModal(
                                user: user,
                                task: data,
                                showRecordedTime: showRecordedTime,
                                notificationCallback: notificationCallback,
                              );
                            });
                      }),
                  series: <CircularSeries>[
                    PieSeries<TaskModel, String>(
                      enableSmartLabels: true,
                      dataSource: _getChartData(
                          categoriesSnapshot.data.documents,
                          tasksSnapshot.data.documents),
                      pointColorMapper: (TaskModel data, _) => data.color,
                      xValueMapper: (TaskModel data, _) => data.id,
                      yValueMapper: (TaskModel data, _) => data.duration,
                      radius: '80%',
                      dataLabelMapper: (TaskModel data, _) => data.name,
                      dataLabelSettings: DataLabelSettings(
                        isVisible: true,
                        useSeriesColor: true,
                      ),
                    )
                  ],
                ),
              );
            },
          );
        });
  }
}
