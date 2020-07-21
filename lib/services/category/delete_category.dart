import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> deleteCategory(oldCategoryName, newCategoryName, user) async {
  final CollectionReference usersRef = Firestore.instance.collection('users');
  final snapShot = await usersRef.document(user.uid).get();

  if (snapShot.exists) {
    // get document reference for old category
    final DocumentReference oldCategoryRef = usersRef
        .document(user.uid)
        .collection('categories')
        .document(oldCategoryName);

    // get document reference for uncategorized
    final DocumentReference newCategoryRef = usersRef
        .document(user.uid)
        .collection('categories')
        .document(newCategoryName);

    // get all tasks under the old category
    final QuerySnapshot tasksSnapShot = await usersRef
        .document(user.uid)
        .collection('tasks')
        .where('category', isEqualTo: oldCategoryRef)
        .getDocuments();

    // update category to uncategorized for each task
    tasksSnapShot.documents.forEach((snapshot) async {
      await snapshot.reference.updateData({
        'category': newCategoryRef,
      });
    });

    // delete the category
    await usersRef
        .document(user.uid)
        .collection('categories')
        .document(oldCategoryName)
        .delete();
  }
}

Future<void> showDeleteCategoryAlert(context, categoryName, user) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Warning!'),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text(
                  'Are you sure you want to delete this category? (This will mark all tasks in this category as uncategorized)'),
              SizedBox(height: 20),
              Text(categoryName),
            ],
          ),
        ),
        actions: <Widget>[
          FlatButton(
            child: Text('No'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          FlatButton(
            child: Text('Yes'),
            onPressed: () {
              Navigator.of(context).pop();
              deleteCategory(categoryName, 'uncategorized', user);
            },
          ),
        ],
      );
    },
  );
}
