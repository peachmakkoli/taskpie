import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:calendar_timeline/calendar_timeline.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:suncircle/screens/landingpage/landingpage.dart';
import 'package:suncircle/screens/homepage/task.dart';


class HomePage extends StatefulWidget {
  HomePage({Key key, this.title, this.user}) : super(key: key);

  final String title;
  final FirebaseUser user;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  
  Future<void> signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
    } catch (error) {
      print(error); // TODO: show dialog with error
    }
  }

  DateTime _selectedDate;
  DateTime _nextDay;

  @override
  void initState() {
    super.initState();
    _resetSelectedDate();
    initializeDateFormatting();
  }

  void _resetSelectedDate() {
    DateTime today = new DateTime.now();
    _selectedDate = DateTime(today.year, today.month, today.day);
  }

  // TODO: Check if a new event has been added so the app can re-render 
  // the calendar circle

  // function with setState that is called anytime the user refreshes the screen
  // map tasks to chartData list
  // query database for all tasks with reference to current user

  // int _counter = 0;

  // void _incrementCounter() {
  //   setState(() {
  //     // This call to setState tells the Flutter framework that something has
  //     // changed in this State, which causes it to rerun the build method below
  //     // so that the display can reflect the updated values. If we changed
  //     // _counter without calling setState(), then the build method would not be
  //     // called again, and so nothing would appear to happen.
  //     _counter++;
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        automaticallyImplyLeading: false,
        actions: <Widget>[
          FlatButton(
            child: Text(
              'Logout',
              style: TextStyle(
                fontSize: 18.0,
                color: Colors.white,
              ),
            ),
            onPressed: () {
              signOut().whenComplete(() {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) {
                      return LandingPage();
                    },
                  ),
                );
              });
            },
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          children: <Widget>[
             CalendarTimeline(
              initialDate: _selectedDate,
              firstDate: DateTime.now().subtract(Duration(days: 365)),
              lastDate: DateTime.now().add(Duration(days: 365)),
              onDateSelected: (date) {
                setState(() {
                  _selectedDate = date;
                  _nextDay = date.add(Duration(days: 1));
                });
              },
              leftMargin: 20,
              monthColor: Colors.black,
              dayColor: Colors.teal[200],
              dayNameColor: Color(0xFF333A47),
              activeDayColor: Colors.white,
              activeBackgroundDayColor: Colors.redAccent[100],
              dotsColor: Color(0xFF333A47),
              selectableDayPredicate: (date) => date.day != 23,
            ),
            // SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.only(left: 16),
              child: FlatButton(
                color: Colors.teal[200],
                child: Text('TODAY', style: TextStyle(color: Color(0xFF333A47))),
                onPressed: () => setState(() => _resetSelectedDate()),
              ),
            ),
            StreamBuilder(
              stream: Firestore.instance
                .collection('users')
                .document(widget.user.uid)
                .collection('tasks')
                .where('time_start', isGreaterThanOrEqualTo: _selectedDate)
                .where('time_start', isLessThan: _nextDay)
                .orderBy('time_start')
                .snapshots(),
              builder: (context, snapshot) {
                if(!snapshot.hasData) return Text('Loading data...');
                if(snapshot.data.documents.isEmpty) return Text('No tasks found for selected day.');
                return Container(
                  height: 400,
                  child: SfCircularChart(series: <CircularSeries>[
                    PieSeries<ChartData, String>(
                      enableSmartLabels: true,
                      dataSource: [ 
                        for (var task in snapshot.data.documents) ChartData(task['name'], 25, task['name'])
                      ],
                      // snapshot.data.documents.map((task) => ChartData(task['name'], 25, task['name'])).toList(),
                      // [
                      //   ChartData('', 25, '', Colors.white),
                      //   ChartData(snapshot.data.documents[0]['name'], 38, snapshot.data.documents[0]['name'], Colors.yellow),
                      //   ChartData('', 4, '', Colors.white),
                      //   ChartData('Task Two', 2, 'Task Two (2 mins)', Colors.orange)
                      // ],
                      pointColorMapper:(ChartData data,  _) => data.color,
                      xValueMapper: (ChartData data, _) => data.x,
                      yValueMapper: (ChartData data, _) => data.y,
                      radius: '90%',
                      // explode: true,
                      // explodeIndex: 0,
                      dataLabelMapper: (ChartData data, _) => data.text,
                      dataLabelSettings: DataLabelSettings(
                        isVisible: true,
                        useSeriesColor: true,
                      ),
                    )
                  ]),
                ); // Column
              },
            ), // Streambuilder
          ], // <Widget>
        ),
      ), // Center
    ); // Scaffold
  }
}

class ChartData {
  ChartData(this.x, this.y, this.text, [this.color]);
  final String x;
  final double y;
  final String text;
  final Color color;
}
