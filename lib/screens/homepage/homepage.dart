import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:custom_horizontal_calendar/custom_horizontal_calendar.dart';
import 'package:custom_horizontal_calendar/date_row.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:suncircle/screens/loginpage/loginpage.dart';
import 'package:unicorndial/unicorndial.dart';
import 'package:suncircle/screens/task/taskform.dart';
import 'package:suncircle/screens/category/categoryform.dart';
import 'package:suncircle/screens/homepage/circlecalendar.dart';
import 'package:suncircle/screens/category/categoryListSheet.dart';

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
    _resetSelectedDate();
    initializeDateFormatting();
    initializePushNotifications();
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

  Future<void> notification(task) async {
    AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
            'channelId', 'channelName', 'channelDescription',
            priority: Priority.High,
            importance: Importance.Max,
            ticker: 'test');

    IOSNotificationDetails iosNotificationDetails = IOSNotificationDetails();

    NotificationDetails notificationDetails =
        NotificationDetails(androidNotificationDetails, iosNotificationDetails);
    await flutterLocalNotificationsPlugin.show(
        0,
        'Your task ${task.name} is starting soon!',
        'Tap to view time recorder',
        notificationDetails);
  }

  Future onSelectNotification(String payload) {
    if (payload != null) {
      print(payload);
    }

    // set navigator to go to another screen
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

  void _resetSelectedDate() {
    DateTime today = new DateTime.now();
    selectedDate = DateTime(today.year, today.month, today.day);
    nextDay = selectedDate.add(Duration(days: 1));
  }

  Future<void> signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
    } catch (error) {
      print(error); // TODO: show dialog with error
    }
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
                      return LoginPage();
                    },
                  ),
                );
              });
            },
          ),
        ],
      ),
      backgroundColor: Colors.white,
      floatingActionButton: UnicornDialer(
        backgroundColor: Color.fromRGBO(255, 255, 255, 0.5),
        parentButtonBackground: Colors.indigo,
        orientation: UnicornOrientation.VERTICAL,
        parentButton: Icon(Icons.add),
        childButtons: _getChildButtons(),
      ),
      body: Stack(
        children: <Widget>[
          circleCalendar(widget.user, selectedDate, nextDay, showRecordedTime,
              notification),
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
                  activeTrackColor: Colors.lightGreenAccent,
                  activeColor: Colors.green,
                ),
              ],
            ),
          ),
          DraggableScrollableSheet(
            minChildSize: 0.14,
            maxChildSize: 1.0,
            initialChildSize: 0.14,
            builder: (BuildContext context, ScrollController scrollController) {
              return categoryListSheet(widget.user, scrollController);
            },
          ),
        ],
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
            background: Colors.indigo,
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
          backgroundColor: Colors.indigo,
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
                        'uncategorized', '', selectedDate, selectedDate),
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
          backgroundColor: Colors.indigo,
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
