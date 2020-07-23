import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:custom_horizontal_calendar/custom_horizontal_calendar.dart';
import 'package:custom_horizontal_calendar/date_row.dart';
import 'package:unicorndial/unicorndial.dart';
import 'package:expandable_bottom_sheet/expandable_bottom_sheet.dart';

import 'package:taskpie/components/circle_calendar.dart';
import 'package:taskpie/models/category_model.dart';
import 'package:taskpie/models/task_model.dart';
import 'package:taskpie/screens/category/category_form.dart';
import 'package:taskpie/screens/category/category_list_sheet.dart';
import 'package:taskpie/screens/task/record_time_page.dart';
import 'package:taskpie/screens/task/task_form.dart';
import 'package:taskpie/services/login/login.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key, this.title, this.user}) : super(key: key);

  final String title;
  final FirebaseUser user;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  AndroidInitializationSettings androidInitializationSettings;
  IOSInitializationSettings iosInitializationSettings;
  InitializationSettings initializationSettings;

  DateTime selectedDate;
  DateTime nextDay;

  bool showRecordedTime = false;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting();
    resetSelectedDate();
    initializePushNotifications();
  }

  void resetSelectedDate() {
    DateTime today = new DateTime.now();
    selectedDate = DateTime(today.year, today.month, today.day);
    nextDay = selectedDate.add(Duration(days: 1));
  }

  void initializePushNotifications() async {
    androidInitializationSettings = AndroidInitializationSettings('app_icon');
    iosInitializationSettings = IOSInitializationSettings(
        onDidReceiveLocalNotification: onDidReceiveLocalNotification);
    initializationSettings = InitializationSettings(
        androidInitializationSettings, iosInitializationSettings);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: onSelectNotification);
  }

  Future<void> notification(
      String taskName, String taskID, DateTime timeStart, DateTime timeEnd,
      [bool cancel]) async {
    int _startNotificationID = Timestamp.fromDate(timeStart).seconds;
    int _endNotificationID = Timestamp.fromDate(timeEnd).seconds;

    if (cancel == true) {
      await flutterLocalNotificationsPlugin.cancel(_startNotificationID);
      await flutterLocalNotificationsPlugin.cancel(_endNotificationID);
      return;
    } else {
      DateTime _scheduledStart = timeStart.subtract(Duration(minutes: 1));

      AndroidNotificationDetails androidNotificationDetails =
          AndroidNotificationDetails(
              taskID, taskName, 'Start: $timeStart, End: $timeEnd',
              priority: Priority.High,
              importance: Importance.Max,
              ticker: 'task alert');

      IOSNotificationDetails iosNotificationDetails = IOSNotificationDetails();

      NotificationDetails notificationDetails = NotificationDetails(
          androidNotificationDetails, iosNotificationDetails);

      await flutterLocalNotificationsPlugin.schedule(
        _startNotificationID,
        'Your task \"$taskName\" is starting soon!',
        'Tap to view time recorder',
        _scheduledStart,
        notificationDetails,
        payload: taskID,
      );

      await flutterLocalNotificationsPlugin.schedule(
        _endNotificationID,
        'Your task \"$taskName\" is ending now!',
        'Tap to open',
        timeEnd,
        notificationDetails,
      );
    }
  }

  Future onSelectNotification(String payload) async {
    if (payload == null) return;
    final CollectionReference usersRef = Firestore.instance.collection('users');
    final _taskDoc = await usersRef
        .document(widget.user.uid)
        .collection('tasks')
        .document(payload)
        .get();

    TaskModel data = TaskModel(
      'category', // this will not be passed to the database
      _taskDoc['name'],
      _taskDoc['time_start'].toDate(),
      _taskDoc['time_end'].toDate(),
      _taskDoc['notes'],
      _taskDoc.documentID,
    );

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          return RecordTimePage(user: widget.user, task: data);
        },
      ),
    );
  }

  Future<CupertinoAlertDialog> onDidReceiveLocalNotification(
      int id, String title, String body, String payload) async {
    return CupertinoAlertDialog(
      title: Text(title),
      content: Text(body),
      actions: <Widget>[
        CupertinoDialogAction(
          isDefaultAction: true,
          onPressed: () {
            print('');
          },
          child: Text('Okay'),
        )
      ],
    );
  }

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
                Navigator.of(context).popUntil((route) => route.isFirst);
              });
            },
          ),
        ],
      ),
      backgroundColor: Colors.white,
      floatingActionButton: UnicornDialer(
        backgroundColor: Color.fromRGBO(255, 255, 255, 0.5),
        parentButtonBackground: Color(0xFF3F88C5),
        orientation: UnicornOrientation.VERTICAL,
        parentButton: Icon(Icons.add),
        childButtons: _getChildButtons(),
      ),
      body: ExpandableBottomSheet(
        background: Stack(
          children: <Widget>[
            CircleCalendar(
              user: widget.user,
              selectedDate: selectedDate,
              nextDay: nextDay,
              showRecordedTime: showRecordedTime,
              notificationCallback: notification,
            ),
            _dayPicker(),
            Align(
              alignment: Alignment(0.0, 0.7),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text('Recorded Tasks'),
                  Switch(
                    value: showRecordedTime,
                    onChanged: (value) {
                      setState(() {
                        showRecordedTime = value;
                      });
                    },
                    activeTrackColor: Color(0xFFA7CCFF),
                    activeColor: Color(0xFF3F88C5),
                  ),
                ],
              ),
            ),
          ],
        ),
        persistentHeader: Container(
          height: 80,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
                topRight: Radius.circular(20), topLeft: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                  color: Colors.black38,
                  offset: Offset(1.0, -2.0),
                  blurRadius: 4.0,
                  spreadRadius: 2.0)
            ],
            color: Color(0xFFF46262),
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 30.0),
              child: Row(
                children: <Widget>[
                  Icon(
                    Icons.drag_handle,
                    size: 40.0,
                    color: Colors.white,
                  ),
                  SizedBox(width: 20),
                  Text(
                    'Categories',
                    style: TextStyle(
                      fontSize: 18.0,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        expandableContent: Container(
          height: MediaQuery.of(context).size.height * .81,
          color: Colors.white,
          child: CategoryListSheet(user: widget.user),
        ),
      ),
    );
  }

  Widget _dayPicker() {
    return CustomHorizontalCalendar(
      onDateChoosen: (date) {
        setState(() {
          selectedDate = date;
          nextDay = date.add(Duration(days: 1));
        });
      },
      inintialDate: selectedDate,
      height: 60,
      builder: (context, index, date, width) {
        if (index != 2)
          return DateRow(
            date,
            width: width,
          );
        else
          return DateRow(
            date,
            background: Color(0xFF3F88C5),
            selectedDayStyle: TextStyle(color: Colors.white),
            selectedDayOfWeekStyle: TextStyle(color: Colors.white),
            selectedMonthStyle: TextStyle(color: Colors.white),
            width: width,
          );
      },
    );
  }

  List<UnicornButton> _getChildButtons() {
    var childButtons = List<UnicornButton>();

    childButtons.add(UnicornButton(
        hasLabel: true,
        labelText: "New Task",
        currentButton: FloatingActionButton(
          heroTag: "task",
          backgroundColor: Color(0xFF3F88C5),
          mini: true,
          child: Icon(Icons.event_note),
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) {
                  return TaskForm(
                    title: widget.title,
                    subtitle: 'Create Task',
                    user: widget.user,
                    task: TaskModel(
                      'uncategorized',
                      '',
                      selectedDate,
                      selectedDate,
                      '',
                    ),
                    showRecordedTime: false,
                  );
                },
              ),
            );
          },
        )));

    childButtons.add(UnicornButton(
        hasLabel: true,
        labelText: "New Category",
        currentButton: FloatingActionButton(
          heroTag: "category",
          backgroundColor: Color(0xFF3F88C5),
          mini: true,
          child: Icon(Icons.label),
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) {
                  return CategoryForm(
                    title: widget.title,
                    subtitle: 'Create Category',
                    user: widget.user,
                    category: CategoryModel('', '00000000'),
                  );
                },
              ),
            );
          },
        )));

    return childButtons;
  }
}
