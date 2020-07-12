import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';


class NewTaskFormBloc extends FormBloc<String, String> {
  final name = TextFieldBloc();

  final timeStart = InputFieldBloc<DateTime, Object>();

  final timeEnd = InputFieldBloc<DateTime, Object>();

  final notes = TextFieldBloc();

  NewTaskFormBloc() {
    addFieldBlocs(fieldBlocs: [
      name,
      timeStart,
      timeEnd,
      notes,
    ]);
  }

  @override
  void onSubmitting() async {
    try {
      await Future<void>.delayed(Duration(milliseconds: 500));
      // send form data to database
      emitSuccess(canSubmitAgain: false);
    } catch (e) {
      emitFailure();
    }
  }
}

class NewTaskForm extends StatelessWidget {
  NewTaskForm({Key key, this.title, this.user}) : super(key: key);

  final String title;
  final FirebaseUser user;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => NewTaskFormBloc(),
      child: Builder(
        builder: (context) {
          final formBloc = BlocProvider.of<NewTaskFormBloc>(context);

          return Theme(
            data: Theme.of(context).copyWith(
              inputDecorationTheme: InputDecorationTheme(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
            child: Scaffold(
              appBar: AppBar(
                title: Text(title),
                // backgroundColor: Color(0xFFFF737D),
              ),
              floatingActionButton: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  FloatingActionButton(
                    onPressed: formBloc.submit,
                    // backgroundColor: Color(0xFF14BDEB),
                    tooltip: 'Submit',
                    child: Icon(Icons.send, size: 30.0),                  
                  ),
                ],
              ),
              body: FormBlocListener<NewTaskFormBloc, String, String>(
                onSubmitting: (context, state) {
                  LoadingDialog.show(context);
                },
                onSuccess: (context, state) {
                  LoadingDialog.hide(context);

                  Navigator.of(context).pop();
                },
                onFailure: (context, state) {
                  LoadingDialog.hide(context);

                  Scaffold.of(context).showSnackBar(
                      SnackBar(content: Text(state.failureResponse)));
                },
                child: SingleChildScrollView(
                  physics: ClampingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: <Widget>[
                        Text(
                          'Add a New Task',
                          style: TextStyle(
                            fontSize: 24,
                            // color: Color(0xFF14BDEB),
                          ),
                        ),
                        TextFieldBlocBuilder(
                          textFieldBloc: formBloc.name,
                          decoration: InputDecoration(
                            labelText: 'Name',
                            prefixIcon: Icon(Icons.text_fields),
                          ),
                        ),
                        DateTimeFieldBlocBuilder(
                          dateTimeFieldBloc: formBloc.timeStart,
                          canSelectTime: true,
                          format: DateFormat.yMMMd().add_jm(),
                          initialDate: DateTime.now(),
                          firstDate: DateTime(1900),
                          lastDate: DateTime(2100),
                          decoration: InputDecoration(
                            labelText: 'Start time',
                            prefixIcon: Icon(Icons.date_range),
                            helperText: 'Date and Time',
                          ),
                        ),
                        DateTimeFieldBlocBuilder(
                          dateTimeFieldBloc: formBloc.timeEnd,
                          canSelectTime: true,
                          format: DateFormat.yMMMd().add_jm(),
                          initialDate: DateTime.now(),
                          firstDate: DateTime(1900),
                          lastDate: DateTime(2100),
                          decoration: InputDecoration(
                            labelText: 'End time',
                            prefixIcon: Icon(Icons.date_range),
                            helperText: 'Date and Time',
                          ),
                        ),
                        TextFieldBlocBuilder(
                          textFieldBloc: formBloc.notes,
                          decoration: InputDecoration(
                            labelText: 'Notes',
                            prefixIcon: Icon(Icons.text_fields),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
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
