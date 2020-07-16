import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:suncircle/screens/task/viewtaskmodal.dart';

Widget circleCalendar(
    FirebaseUser user, DateTime selectedDate, DateTime nextDay) {
  return StreamBuilder(
      stream: Firestore.instance
          .collection('users')
          .document(user.uid)
          .collection('categories')
          .snapshots(),
      builder: (context, snapshot1) {
        return StreamBuilder(
          stream: Firestore.instance
              .collection('users')
              .document(user.uid)
              .collection('tasks')
              .where('time_start', isGreaterThanOrEqualTo: selectedDate)
              .where('time_start', isLessThan: nextDay)
              .orderBy('time_start')
              .snapshots(),
          builder: (context, snapshot2) {
            if (!snapshot1.hasData || !snapshot2.hasData)
              return Container(
                  height: MediaQuery.of(context).size.height,
                  alignment: Alignment(0.0, 0.0),
                  child: Text('Loading data...'));
            if (snapshot2.data.documents.isEmpty)
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
                      viewTaskModal(context, user, data);
                    }),
                series: <CircularSeries>[
                  PieSeries<ChartData, String>(
                    enableSmartLabels: true,
                    dataSource: _getChartData(snapshot1.data.documents,
                        snapshot2.data.documents, selectedDate, nextDay),
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

double _getDuration(Timestamp timeEnd, Timestamp timeStart) {
  return (timeEnd.seconds - timeStart.seconds) / 3600;
}

Color _getColor(category) {
  return Color(int.parse('0x${category['color']}'));
}

List<ChartData> _getChartData(categories, tasks, selectedDate, nextDay) {
  List<ChartData> _chartData = List<ChartData>();

  // add white space between start of day and start of first task
  _chartData.add(ChartData(
    '',
    'free time',
    '',
    DateTime.now(),
    DateTime.now(),
    '',
    _getDuration(tasks[0]['time_start'], Timestamp.fromDate(selectedDate)),
    Colors.white,
  ));

  for (var i = 0; i < tasks.length; i++) {
    var category = categories.firstWhere(
      (category) => category.reference.path == tasks[i]['category'].path,
    );

    _chartData.add(ChartData(
      tasks[i].documentID,
      category.documentID,
      tasks[i]['name'],
      tasks[i]['time_start'].toDate(),
      tasks[i]['time_end'].toDate(),
      tasks[i]['notes'],
      _getDuration(tasks[i]['time_end'], tasks[i]['time_start']),
      _getColor(category),
    ));

    // add white space between tasks
    if (i < tasks.length - 1) {
      _chartData.add(ChartData(
          '',
          'free time',
          '',
          DateTime.now(),
          DateTime.now(),
          '',
          _getDuration(tasks[i + 1]['time_start'], tasks[i]['time_end']),
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
          tasks[tasks.length - 1]['time_end']),
      Colors.white));

  return _chartData;
}

class ChartData {
  ChartData(this.id, this.category, this.name, this.timeStart, this.timeEnd,
      this.notes, this.duration,
      [this.color]);
  final String id;
  final String category;
  final String name;
  final DateTime timeStart;
  final DateTime timeEnd;
  final double duration;
  final String notes;
  final Color color;
}
