import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';
import 'package:suncircle/screens/taskform/taskform.dart';
import 'package:suncircle/screens/taskform/deletetask.dart';


Widget circleCalendar(FirebaseUser user, DateTime selectedDate, DateTime nextDay) {
  return StreamBuilder(
    stream: Firestore.instance
      .collection('users')
      .document(user.uid)
      .collection('tasks')
      .where('time_start', isGreaterThanOrEqualTo: selectedDate)
      .where('time_start', isLessThan: nextDay)
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
        height: MediaQuery.of(context).size.height / 1.5,
        alignment: Alignment(0.0, 0.0),
        child: SfCircularChart(
          tooltipBehavior: TooltipBehavior(
            enable: true,
            activationMode: ActivationMode.longPress,
            builder: (dynamic data, dynamic point, dynamic series, int pointIndex, int seriesIndex) {
              _viewTaskModal(context, user, data);
            }
          ),
          series: <CircularSeries>[
            PieSeries<ChartData, String>(
              enableSmartLabels: true,
              dataSource: _getChartData(snapshot.data.documents, selectedDate, nextDay),
              pointColorMapper:(ChartData data,  _) => data.color,
              xValueMapper: (ChartData data, _) => data.id,
              yValueMapper: (ChartData data, _) => data.duration,
              radius: '80%',
              // explode: true,
              // explodeIndex: 0,
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
}

void _viewTaskModal(context, FirebaseUser user, dynamic data) {
  if (data.id.isEmpty) return null; // prevents placeholders from being tapped

  int durationHour = data.duration.floor();
  int durationMinute = ((data.duration - data.duration.floor()) * 60).floor();

  showModalBottomSheet(context: context, builder: (BuildContext bc) {
    return Container(
      height: MediaQuery.of(context).size.height * .40,
      child: Padding(
        padding: EdgeInsets.fromLTRB(24.0, 16.0, 24.0, 16.0),
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
                  icon: Icon(Icons.close, color: Colors.red, size: 25,),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
            Text('Start: ' + DateFormat.yMMMd().add_jm().format(data.timeStart)),
            SizedBox(height: 10),
            Text('End: ' + DateFormat.yMMMd().add_jm().format(data.timeEnd)),
            SizedBox(height: 10),
            Text('Duration: $durationHour h $durationMinute m'),
            SizedBox(height: 10),
            Text('Notes: ' + data.notes),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                IconButton(
                  tooltip: 'Edit task',
                  icon: Icon(Icons.create, size: 40,),
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) {
                          return TaskForm(
                            title: 'TaskPie', 
                            subtitle: 'Update Task',
                            user: user, 
                            task: TaskModel(data.name, data.timeStart, data.timeEnd, data.notes, data.id),
                          );
                        },
                      ),
                    );
                  },
                ),
                IconButton(
                  tooltip: 'Delete task',
                  icon: Icon(Icons.delete_outline, size: 40,),
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

List<ChartData> _getChartData(tasks, selectedDate, nextDay) {
    List<ChartData> _chartData = List<ChartData>();
    double _getDuration(Timestamp timeEnd, Timestamp timeStart) {
      return (timeEnd.seconds - timeStart.seconds) / 3600;
    }

    // add white space between start of day and start of first task
    _chartData.add(ChartData(
      '',
      '',
      DateTime.now(),
      DateTime.now(),
      '',
      _getDuration(tasks[0]['time_start'], Timestamp.fromDate(selectedDate)), 
      Colors.white,
    ));

    for (var i = 0; i < tasks.length; i++) {
      _chartData.add(ChartData(
        tasks[i].documentID, 
        tasks[i]['name'],
        tasks[i]['time_start'].toDate(),
        tasks[i]['time_end'].toDate(),
        tasks[i]['notes'],
        _getDuration(tasks[i]['time_end'], tasks[i]['time_start']), 
      ));
      
      // add white space between tasks
      if (i < tasks.length - 1) {
        _chartData.add(ChartData(
          '',
          '',
          DateTime.now(),
          DateTime.now(),
          '',
          _getDuration(tasks[i+1]['time_start'], tasks[i]['time_end']), 
          Colors.white
        ));
      }
    }

    // add white space between end of last task and end of day
    _chartData.add(ChartData(
      '',
      '',
      DateTime.now(),
      DateTime.now(),
      '', 
      _getDuration(Timestamp.fromDate(selectedDate.add(Duration(days: 1))), tasks[tasks.length - 1]['time_end']), 
      Colors.white
    )); 
    
    return _chartData;
  }

class ChartData {
  ChartData(this.id, this.name, this.timeStart, this.timeEnd, this.notes, this.duration, [this.color]);
  final String id;
  final String name;
  final DateTime timeStart;
  final DateTime timeEnd;
  final double duration;
  final String notes;
  final Color color;
}
