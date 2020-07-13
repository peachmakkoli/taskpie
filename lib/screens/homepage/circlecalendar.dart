import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';


Widget circleCalendar(user, _selectedDate, _nextDay) {
  return StreamBuilder(
    stream: Firestore.instance
      .collection('users')
      .document(user.uid)
      .collection('tasks')
      .where('time_start', isGreaterThanOrEqualTo: _selectedDate)
      .where('time_start', isLessThan: _nextDay)
      .orderBy('time_start')
      .snapshots(),
    builder: (context, snapshot) {
      if(!snapshot.hasData) return Text('Loading data...');
      if(snapshot.data.documents.isEmpty) return Text('No tasks found for selected day.');
      return Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: ExactAssetImage("assets/clock-face.png"), 
            fit: BoxFit.contain,
          ),
        ),
        height: 420,
        child: SfCircularChart(series: <CircularSeries>[
          PieSeries<ChartData, String>(
            enableSmartLabels: true,
            dataSource: _getChartData(snapshot.data.documents, _selectedDate, _nextDay),
            pointColorMapper:(ChartData data,  _) => data.color,
            xValueMapper: (ChartData data, _) => data.x,
            yValueMapper: (ChartData data, _) => data.y,
            radius: '80%',
            // explode: true,
            // explodeIndex: 0,
            dataLabelMapper: (ChartData data, _) => data.text,
            dataLabelSettings: DataLabelSettings(
              isVisible: true,
              useSeriesColor: true,
            ),
          )
        ]),
      ); 
    },
  ); 
}

List<ChartData> _getChartData(tasks, _selectedDate, _nextDay) {
    List<ChartData> _chartData = List<ChartData>();

    // add white space between start of day and start of first task
    _chartData.add(new ChartData(
      '', 
      (tasks[0]['time_start'].seconds - Timestamp.fromDate(_selectedDate).seconds).toDouble(), 
      '', 
      Colors.white
    ));

    for (var i = 0; i < tasks.length; i++) {
      var name = tasks[i]['name'];
      var size = (tasks[i]['time_end'].seconds - tasks[i]['time_start'].seconds).toDouble();
      var duration = size / 3600; // converts to hours

      _chartData.add(new ChartData(name, size, name + '\n($duration hrs)'));
      
      // add white space between tasks
      if (i < tasks.length - 1) {
        _chartData.add(new ChartData(
          '', 
          (tasks[i+1]['time_start'].seconds - tasks[i]['time_end'].seconds).toDouble(), 
          '', 
          Colors.white
        ));
      }
    }

    // add white space between end of last task and end of day
    _chartData.add(new ChartData(
      '', 
      (Timestamp.fromDate(_selectedDate.add(Duration(days: 1))).seconds - tasks[tasks.length - 1]['time_end'].seconds).toDouble(), 
      '', 
      Colors.white
    )); 
    
    return _chartData;
  }

class ChartData {
  ChartData(this.x, this.y, this.text, [this.color]);
  final String x;
  final double y;
  final String text;
  final Color color;
}