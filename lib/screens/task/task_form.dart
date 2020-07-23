import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:firebase_auth/firebase_auth.dart';

import 'package:card_settings/card_settings.dart';
import 'package:expandable_bottom_sheet/expandable_bottom_sheet.dart';

import 'package:taskpie/components/circle_calendar.dart';
import 'package:taskpie/components/loading_dialog.dart';
import 'package:taskpie/components/submit_form_button.dart';
import 'package:taskpie/models/task_model.dart';
import 'package:taskpie/services/task/save_task.dart';

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
  bool _autoValidate = false;

  @override
  void initState() {
    super.initState();
    initModel();
    resetSelectedDate();
  }

  void initModel() {
    _task = widget.task;
  }

  void resetSelectedDate() {
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

  Future submitForm() async {
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
      ),
      backgroundColor: Colors.white,
      floatingActionButton: submitFormButton(context, submitForm),
      body: FutureBuilder(
        future: getCategories(widget.user),
        builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
          if (!snapshot.hasData)
            return Container(
                height: MediaQuery.of(context).size.height,
                alignment: Alignment(0.0, 0.0),
                child: Text('Baking...'));
          return FutureBuilder<bool>(
              future: isOverlapPartial(
                widget.user,
                'time_start',
                widget.showRecordedTime ? _task.recordStart : _task.timeStart,
                widget.showRecordedTime ? _task.recordEnd : _task.timeEnd,
              ),
              builder: (context, snapshotEndOverlapPartial) {
                return FutureBuilder<bool>(
                    future: isOverlapPartial(
                      widget.user,
                      'time_end',
                      widget.showRecordedTime
                          ? _task.recordStart
                          : _task.timeStart,
                      widget.showRecordedTime ? _task.recordEnd : _task.timeEnd,
                    ),
                    builder: (context, snapshotStartOverlapPartial) {
                      return FutureBuilder<bool>(
                          future: isOverlapComplete(
                            widget.user,
                            widget.showRecordedTime
                                ? _task.recordStart
                                : _task.timeStart,
                            widget.showRecordedTime
                                ? _task.recordEnd
                                : _task.timeEnd,
                          ),
                          builder: (context, snapshotOverlapComplete) {
                            return ExpandableBottomSheet(
                              background: Form(
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
                                          initialValue: widget.showRecordedTime
                                              ? _task.recordStart
                                              : _task.timeStart,
                                          requiredIndicator: Text('*',
                                              style:
                                                  TextStyle(color: Colors.red)),
                                          firstDate: DateTime(1900),
                                          lastDate: DateTime(2100),
                                          validator: (value) {
                                            if (snapshotStartOverlapPartial
                                                        .data ==
                                                    true ||
                                                snapshotOverlapComplete.data ==
                                                    true)
                                              return 'Start time overlaps another task.';
                                          },
                                          onChanged: (value) {
                                            setState(() {
                                              widget.showRecordedTime
                                                  ? _task.recordStart = value
                                                  : _task.timeStart = value;
                                              resetSelectedDate();
                                            });
                                          },
                                        ),
                                        CardSettingsDateTimePicker(
                                          label: 'End',
                                          initialValue: widget.showRecordedTime
                                              ? _task.recordEnd
                                              : _task.timeEnd,
                                          requiredIndicator: Text('*',
                                              style:
                                                  TextStyle(color: Colors.red)),
                                          firstDate: DateTime(1900),
                                          lastDate: DateTime(2100),
                                          validator: (value) {
                                            if (widget.showRecordedTime
                                                ? value
                                                    .isBefore(_task.recordStart)
                                                : value
                                                    .isBefore(_task.timeStart))
                                              return 'End cannot be before start.';
                                            if (snapshotEndOverlapPartial
                                                        .data ==
                                                    true ||
                                                snapshotOverlapComplete.data ==
                                                    true)
                                              return 'End time overlaps another task.';
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
                                              style:
                                                  TextStyle(color: Colors.red)),
                                          validator: (value) {
                                            if (value.isEmpty)
                                              return 'Name is required.';
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
                                              style:
                                                  TextStyle(color: Colors.red)),
                                          options:
                                              getCategoryList(snapshot.data),
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
                              persistentHeader: Container(
                                height: 90,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.only(
                                      topRight: Radius.circular(20),
                                      topLeft: Radius.circular(20)),
                                  boxShadow: [
                                    BoxShadow(
                                        color: Colors.blueGrey[100],
                                        offset: Offset(1.0, -2.0),
                                        blurRadius: 4.0,
                                        spreadRadius: 2.0)
                                  ],
                                  color: Color(0xFFFF737D),
                                ),
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 30.0),
                                    child: Row(
                                      children: <Widget>[
                                        Icon(Icons.drag_handle, size: 40.0),
                                        SizedBox(width: 20),
                                        Text(
                                          'Schedule',
                                          style: TextStyle(fontSize: 18.0),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              expandableContent: Container(
                                height: MediaQuery.of(context).size.height * .6,
                                color: Colors.white,
                                child: CircleCalendar(
                                  user: widget.user,
                                  selectedDate: selectedDate,
                                  nextDay: nextDay,
                                  showRecordedTime: false,
                                ),
                              ),
                            );
                          });
                    });
              });
        },
      ),
    );
  }
}
