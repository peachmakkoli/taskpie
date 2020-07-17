import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:card_settings/card_settings.dart';
import 'package:suncircle/screens/task/savetask.dart';
import 'package:suncircle/screens/homepage/circlecalendar.dart';
import 'package:suncircle/loadingdialog.dart';

final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

class TaskForm extends StatefulWidget {
  TaskForm({Key key, this.title, this.subtitle, this.user, this.task})
      : super(key: key);

  final String title;
  final String subtitle;
  final FirebaseUser user;
  TaskModel task;

  @override
  TaskFormState createState() => TaskFormState();
}

class TaskFormState extends State<TaskForm> {
  TaskModel _task;

  DateTime selectedDate;
  DateTime nextDay;

  bool _autoValidate = false;

  @override
  void initState() {
    super.initState();
    initModel();
    _resetSelectedDate();
  }

  void initModel() {
    _task = widget.task;
  }

  void _resetSelectedDate() {
    selectedDate = DateTime(
        _task.timeStart.year, _task.timeStart.month, _task.timeStart.day);
    nextDay = selectedDate.add(Duration(days: 1));
  }

  List<String> getCategoryList(categories) {
    List<String> _categoryNames = List<String>();

    for (var category in categories) {
      _categoryNames.add(category.documentID);
    }

    return _categoryNames;
  }

  Future savePressed() async {
    final form = _formKey.currentState;

    LoadingDialog.show(context);

    if (form.validate()) {
      saveTask(_task, widget.user).whenComplete(() {
        LoadingDialog.hide(context);
        Navigator.of(context).pop();
      });
    } else {
      LoadingDialog.hide(context);
      setState(() => _autoValidate = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('${widget.title}: ${widget.subtitle}'),
          // backgroundColor: Color(0xFFFF737D),
        ),
        backgroundColor: Colors.white,
        floatingActionButton: _submitFormButton(),
        body: FutureBuilder(
            future: getCategories(widget.user),
            builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
              if (!snapshot.hasData) return Center(child: Text('Loading...'));
              return Stack(
                children: <Widget>[
                  Form(
                    key: _formKey,
                    child: CardSettings.sectioned(
                      showMaterialonIOS: false,
                      labelWidth: 150,
                      contentAlign: TextAlign.right,
                      children: <CardSettingsSection>[
                        CardSettingsSection(
                          header: CardSettingsHeader(
                            label: 'Date and Time',
                          ),
                          children: <CardSettingsWidget>[
                            CardSettingsDateTimePicker(
                              label: 'Start',
                              initialValue: _task.timeStart,
                              requiredIndicator: Text('*',
                                  style: TextStyle(color: Colors.red)),
                              firstDate: DateTime(1900),
                              lastDate: DateTime(2100),
                              onChanged: (value) {
                                setState(() {
                                  _task.timeStart = value;
                                  _resetSelectedDate();
                                });
                              },
                            ),
                            CardSettingsDateTimePicker(
                              label: 'End',
                              initialValue: _task.timeEnd,
                              requiredIndicator: Text('*',
                                  style: TextStyle(color: Colors.red)),
                              firstDate: DateTime(1900),
                              lastDate: DateTime(2100),
                              validator: (value) {
                                if (value.isBefore(_task.timeStart))
                                  return 'End time cannot be before start time.';
                              },
                              onChanged: (value) {
                                setState(() {
                                  _task.timeEnd = value;
                                });
                              },
                            ),
                          ],
                        ),
                        CardSettingsSection(
                          header: CardSettingsHeader(
                            label: 'Info',
                          ),
                          children: <CardSettingsWidget>[
                            CardSettingsText(
                              label: 'Name',
                              initialValue: _task.name,
                              requiredIndicator: Text('*',
                                  style: TextStyle(color: Colors.red)),
                              validator: (value) {
                                if (value.isEmpty) return 'Name is required.';
                              },
                              onChanged: (value) {
                                setState(() {
                                  _task.name = value;
                                });
                              },
                            ),
                            CardSettingsSelectionPicker(
                              label: 'Category',
                              initialValue: _task.category,
                              requiredIndicator: Text('*',
                                  style: TextStyle(color: Colors.red)),
                              options: getCategoryList(snapshot.data),
                              onChanged: (value) {
                                setState(() {
                                  _task.category = value;
                                });
                              },
                            ),
                            CardSettingsParagraph(
                              label: 'Notes',
                              initialValue: _task.notes,
                              onChanged: (value) {
                                setState(() {
                                  _task.notes = value;
                                });
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  DraggableScrollableSheet(
                    minChildSize: 0.14,
                    maxChildSize: 0.9,
                    initialChildSize: 0.14,
                    builder: (BuildContext context,
                        ScrollController scrollController) {
                      return Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                              topRight: Radius.circular(30),
                              topLeft: Radius.circular(30)),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.grey,
                                offset: Offset(1.0, -2.0),
                                blurRadius: 4.0,
                                spreadRadius: 2.0)
                          ],
                          color: Colors.white,
                        ),
                        child: ListView(
                          controller: scrollController,
                          children: <Widget>[
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Padding(
                                padding: EdgeInsets.fromLTRB(24, 16, 24, 16),
                                child: Text(
                                  'Task Chart',
                                  style: Theme.of(context).textTheme.headline6,
                                ),
                              ),
                            ),
                            Center(
                              child: circleCalendar(
                                  widget.user, selectedDate, nextDay),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              );
            }));
  }

  Widget _submitFormButton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        FloatingActionButton(
          onPressed: () {
            savePressed();
          },
          tooltip: 'Submit',
          child: Icon(Icons.send, size: 30.0),
        ),
      ],
    );
  }
}

class TaskModel {
  TaskModel(this.category, this.name, this.timeStart, this.timeEnd,
      [this.notes, this.id]);
  String category;
  String name;
  DateTime timeStart;
  DateTime timeEnd;
  String notes;
  String id;
}
