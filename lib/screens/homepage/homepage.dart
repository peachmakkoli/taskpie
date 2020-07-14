import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:custom_horizontal_calendar/custom_horizontal_calendar.dart';
import 'package:custom_horizontal_calendar/date_row.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:suncircle/screens/landingpage/landingpage.dart';
import 'package:suncircle/screens/taskform/taskform.dart';
import 'package:suncircle/screens/homepage/circlecalendar.dart';



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

  DateTime selectedDate;
  DateTime nextDay;

  @override
  void initState() {
    super.initState();
    _resetSelectedDate();
    initializeDateFormatting();
  }

  void _resetSelectedDate() {
    DateTime today = new DateTime.now();
    selectedDate = DateTime(today.year, today.month, today.day);
    nextDay = selectedDate.add(Duration(days: 1));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        // backgroundColor: Color(0xFFFF737D),
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
      floatingActionButton: _newTaskButton(),
      body: Center(
        child: Column(
          children: <Widget>[
            _dayPicker(),
            SizedBox(height: 30),
            circleCalendar(widget.user, selectedDate, nextDay),
          ], 
        ),
      ),
    );
  }

  Widget _dayPicker() {
    return CustomHorizontalCalendar(
      onDateChoosen: (date){
        setState(() {
          selectedDate = date;
          nextDay = date.add(Duration(days: 1));
        });
      },
      inintialDate: selectedDate,
      height: 60,
      builder: (context, i, d, width) {
        if (i != 2)
          return DateRow(
            d,
            width: width,
          );
        else
          return DateRow(
            d,
            background: Colors.indigo,
            selectedDayStyle: TextStyle(color: Colors.white),
            selectedDayOfWeekStyle: TextStyle(color: Colors.white),
            selectedMonthStyle: TextStyle(color: Colors.white),width: width,
          );
      },
    );
  }

  Widget _newTaskButton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[ 
        FloatingActionButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) {
                  return TaskForm(
                    title: widget.title, 
                    subtitle: 'Create Task',
                    user: widget.user, 
                    task: TaskModel('', DateTime.now(), DateTime.now()),
                  );
                },
              ),
            );
          },
          tooltip: 'Add a new task',
          child: Icon(Icons.add, size: 40.0),                  
        ),
      ],
    );
  }
}
