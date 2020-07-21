import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:firebase_auth/firebase_auth.dart';

import 'package:card_settings/card_settings.dart';

import 'package:suncircle/components/circle_calendar.dart';
import 'package:suncircle/models/loading_dialog.dart';
import 'package:suncircle/models/task_model.dart';
import 'package:suncircle/services/task/save_task.dart';

class TaskForm extends StatefulWidget {
  TaskForm(
      {Key key,
      this.title,
      this.subtitle,
      this.user,
      this.task,
      this.showRecordedTime})
      : super(key: key);

  final String title;
  final String subtitle;
  final FirebaseUser user;
  final TaskModel task;
  final bool showRecordedTime;

  @override
  TaskFormState createState() => TaskFormState();
}

class TaskFormState extends State<TaskForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  TaskModel _task;
  DateTime selectedDate;
  DateTime nextDay;
  DateTime _fieldStart;
  DateTime _fieldEnd;
  bool _autoValidate = false;

  @override
  void initState() {
    super.initState();
    initModel();
    _resetSelectedDate();
    _toggleTime();
  }

  void initModel() {
    _task = widget.task;
  }

  void _resetSelectedDate() {
    selectedDate = DateTime(
        _task.timeStart.year, _task.timeStart.month, _task.timeStart.day);
    nextDay = selectedDate.add(Duration(days: 1));
  }

  void _toggleTime() {
    if (widget.showRecordedTime) {
      _fieldStart = _task.recordStart;
      _fieldEnd = _task.recordEnd;
    } else {
      _fieldStart = _task.timeStart;
      _fieldEnd = _task.timeEnd;
    }
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
                              initialValue: _fieldStart,
                              requiredIndicator: Text('*',
                                  style: TextStyle(color: Colors.red)),
                              firstDate: DateTime(1900),
                              lastDate: DateTime(2100),
                              onChanged: (value) {
                                setState(() {
                                  widget.showRecordedTime
                                      ? _task.recordStart = value
                                      : _task.timeStart = value;
                                  _resetSelectedDate();
                                });
                              },
                            ),
                            CardSettingsDateTimePicker(
                              label: 'End',
                              initialValue: _fieldEnd,
                              requiredIndicator: Text('*',
                                  style: TextStyle(color: Colors.red)),
                              firstDate: DateTime(1900),
                              lastDate: DateTime(2100),
                              validator: (value) {
                                if (widget.showRecordedTime
                                    ? value.isBefore(_task.recordStart)
                                    : value.isBefore(_task.timeStart))
                                  return 'End cannot be before start.';
                              },
                              onChanged: (value) {
                                setState(() {
                                  widget.showRecordedTime
                                      ? _task.recordEnd = value
                                      : _task.timeEnd = value;
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
                                  widget.user, selectedDate, nextDay, false),
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
