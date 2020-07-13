import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:card_settings/card_settings.dart';
import 'package:intl/intl.dart';
import 'package:suncircle/screens/newtaskform/savetask.dart';


final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

class NewTaskForm extends StatefulWidget {
  NewTaskForm({Key key, this.title}) : super(key: key);

  final String title;

  @override
  NewTaskFormState createState() => NewTaskFormState();
}

class NewTaskFormState extends State<NewTaskForm>{
  TaskModel _task;

  bool _autoValidate = false;

  @override
  void initState() {
    super.initState();
    initModel();
  }

  void initModel() {
    _task = TaskModel('', DateTime.now(), DateTime.now());
  }

  Future savePressed() async {
    final form = _formKey.currentState;

    LoadingDialog.show(context);

    if (form.validate()) {
      saveTask(_task).whenComplete(() {
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
        title: Text(widget.title),
        // backgroundColor: Color(0xFFFF737D),
      ),
      backgroundColor: Colors.white,
      floatingActionButton: _submitFormButton(),
      body: Form(
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
                  requiredIndicator: Text('*', style: TextStyle(color: Colors.red)),
                  firstDate: DateTime(1900),
                  lastDate: DateTime(2100),
                  onChanged: (value) {
                    setState(() {
                      _task.timeStart = value;
                    });
                  },
                ),
                CardSettingsDateTimePicker(
                  label: 'End',
                  initialValue: _task.timeEnd,
                  requiredIndicator: Text('*', style: TextStyle(color: Colors.red)),
                  firstDate: DateTime(1900),
                  lastDate: DateTime(2100),
                  validator: (value) {
                    if (value.isBefore(_task.timeStart)) return 'End time cannot be before start time.';
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
                  requiredIndicator: Text('*', style: TextStyle(color: Colors.red)),
                  validator: (value) {
                    if (value.isEmpty) return 'Name is required.';
                  },
                  onChanged: (value) {
                    setState(() {
                      _task.name = value;
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
    );
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

class LoadingDialog extends StatelessWidget {
  static void show(BuildContext context, {Key key}) => showDialog<void>(
        context: context,
        useRootNavigator: false,
        barrierDismissible: false,
        builder: (_) => LoadingDialog(key: key),
      ).then((_) => FocusScope.of(context).requestFocus(FocusNode()));

  static void hide(BuildContext context) => Navigator.pop(context);

  LoadingDialog({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Center(
        child: Card(
          child: Container(
            width: 80,
            height: 80,
            padding: EdgeInsets.all(12.0),
            child: CircularProgressIndicator(),
          ),
        ),
      ),
    );
  }
}

class TaskModel {
  TaskModel(this.name, this.timeStart, this.timeEnd, [this.notes]);
  String name;
  DateTime timeStart;
  DateTime timeEnd;
  String notes;
}
