import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
// import 'package:flutter_form_bloc/flutter_form_bloc.dart';
import 'package:card_settings/card_settings.dart';
import 'package:intl/intl.dart';


// class NewTaskFormBloc extends FormBloc<String, String> {
//   final name = TextFieldBloc();

//   final timeStart = InputFieldBloc<DateTime, Object>();

//   final timeEnd = InputFieldBloc<DateTime, Object>();

//   final notes = TextFieldBloc();

//   NewTaskFormBloc() {
//     addFieldBlocs(fieldBlocs: [
//       name,
//       timeStart,
//       timeEnd,
//       notes,
//     ]);
//   }

//   @override
//   void onSubmitting() async {
//     try {
//       final FirebaseUser user = await _auth.currentUser();

//       final CollectionReference usersRef = Firestore.instance.collection('users');
//       final snapShot = await usersRef.document(user.uid).get();

//       // check whether the task is split over two days (e.g., sleep)
//       if (timeStart.value.day != timeEnd.value.day) {
//         var taskData1 = {
//           'name': name.value,
//           'time_start': timeStart.value,
//           'time_end': new DateTime(timeStart.value.year, timeStart.value.month, timeStart.value.day, 23, 59, 59, 59, 59),
//           'notes': notes.value,
//         };

//         var taskData2 = {
//           'name': name.value,
//           'time_start': new DateTime(timeEnd.value.year, timeEnd.value.month, timeEnd.value.day),
//           'time_end': timeEnd.value,
//           'notes': notes.value,
//         }; 

//         await usersRef.document(user.uid).collection('tasks').document().setData(taskData1);
//         await usersRef.document(user.uid).collection('tasks').document().setData(taskData2);
//       }
//       else {
//         var taskData = {
//           'name': name.value,
//           'time_start': timeStart.value,
//           'time_end': timeEnd.value,
//           'notes': notes.value,
//         };

//         await usersRef.document(user.uid).collection('tasks').document().setData(taskData);
//       }
//       emitSuccess(canSubmitAgain: false);
//     } catch (e) {
//       emitFailure();
//     }
//   }
// }

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

    if (form.validate()) {
      // send data to database
    } else {
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
          // labelWidth: 150,
          // contentAlign: TextAlign.right,
          // cardless: false,
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
                  // onSaved: (value) => _task.timeStart = value,
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
                  // onSaved: (value) => _task.timeEnd = value,
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
                  // onSaved: (value) => _task.name = value,
                  onChanged: (value) {
                    setState(() {
                      _task.name = value;
                    });
                  },
                ),
                CardSettingsParagraph(
                  label: 'Notes',
                  initialValue: _task.notes,
                  // onSaved: (value) => _task.notes = value,
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
