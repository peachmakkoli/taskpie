import 'package:flutter/material.dart';

Widget submitFormButton(BuildContext context, Function submitForm) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.center,
    mainAxisSize: MainAxisSize.max,
    mainAxisAlignment: MainAxisAlignment.end,
    children: <Widget>[
      FloatingActionButton.extended(
        onPressed: () {
          submitForm();
        },
        tooltip: 'Save',
        icon: Icon(Icons.save_alt, size: 30.0),
        label: Text('SAVE'),
      ),
    ],
  );
}
