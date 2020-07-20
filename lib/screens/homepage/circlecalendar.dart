import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:suncircle/screens/task/viewtaskmodal.dart';

Widget circleCalendar(FirebaseUser user, DateTime selectedDate,
    DateTime nextDay, bool showRecordedTime,
    [Function(dynamic) notification]) {
  String _fieldStart;
  String _fieldEnd;

  if (showRecordedTime) {
    _fieldStart = 'record_start';
    _fieldEnd = 'record_end';
  } else {
    _fieldStart = 'time_start';
    _fieldEnd = 'time_end';
  }

  double _getDuration(Timestamp timeEnd, Timestamp timeStart) {
    if (timeEnd == null || timeStart == null) return 0.0;
    return (timeEnd.seconds - timeStart.seconds) / 3600;
  }

  Color _getColor(category) {
    return Color(int.parse('0x${category['color']}'));
  }

  List<ChartData> _getChartData(categories, tasks) {
    List<ChartData> _chartData = List<ChartData>();
    // add white space between start of day and start of first task
    _chartData.add(ChartData(
      '',
      'free time',
      '',
      DateTime.now(),
      DateTime.now(),
      '',
      _getDuration(tasks[0][_fieldStart], Timestamp.fromDate(selectedDate)),
      Colors.white,
    ));

    for (var i = 0; i < tasks.length; i++) {
      var category = categories.firstWhere(
        (category) => category.reference.path == tasks[i]['category'].path,
      );

      var _task = ChartData(
        tasks[i].documentID,
        category.documentID,
        tasks[i]['name'],
        tasks[i]['time_start'].toDate(),
        tasks[i]['time_end'].toDate(),
        tasks[i]['notes'],
        _getDuration(tasks[i][_fieldEnd], tasks[i][_fieldStart]),
        _getColor(category),
      );

      if (tasks[i]['record_start'] != null) {
        _task.recordStart = tasks[i]['record_start'].toDate();
      }

      if (tasks[i]['record_end'] != null) {
        _task.recordEnd = tasks[i]['record_end'].toDate();
      }

      _chartData.add(_task);

      // add white space between tasks
      if (i < tasks.length - 1) {
        _chartData.add(ChartData(
            '',
            'free time',
            '',
            DateTime.now(),
            DateTime.now(),
            '',
            _getDuration(tasks[i + 1][_fieldStart], tasks[i][_fieldEnd]),
            Colors.white));
      }
    }

    // add white space between end of last task and end of day
    _chartData.add(ChartData(
        '',
        'free time',
        '',
        DateTime.now(),
        DateTime.now(),
        '',
        _getDuration(Timestamp.fromDate(selectedDate.add(Duration(days: 1))),
            tasks[tasks.length - 1][_fieldEnd]),
        Colors.white));

    return _chartData;
  }

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
                  child: Text('Loading data...'));
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
                      viewTaskModal(
                          context, user, data, showRecordedTime, notification);
                    }),
                series: <CircularSeries>[
                  PieSeries<ChartData, String>(
                    enableSmartLabels: true,
                    dataSource: _getChartData(categoriesSnapshot.data.documents,
                        tasksSnapshot.data.documents),
                    pointColorMapper: (ChartData data, _) => data.color,
                    xValueMapper: (ChartData data, _) => data.id,
                    yValueMapper: (ChartData data, _) => data.duration,
                    radius: '80%',
                    // explode: true,
                    dataLabelMapper: (ChartData data, _) => data.name,
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

class ChartData {
  ChartData(this.id, this.category, this.name, this.timeStart, this.timeEnd,
      this.notes, this.duration,
      [this.color, this.recordStart, this.recordEnd]);
  final String id;
  final String category;
  final String name;
  final DateTime timeStart;
  final DateTime timeEnd;
  final double duration;
  final String notes;
  final Color color;
  DateTime recordStart;
  DateTime recordEnd;
  bool alertSet = false;
}
