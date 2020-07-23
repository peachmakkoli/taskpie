import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

Future<void> saveTask(task, user) async {
  final CollectionReference usersRef = Firestore.instance.collection('users');
  final snapShot = await usersRef.document(user.uid).get();

  if (snapShot.exists) {
    final DocumentReference categoryRef = usersRef
        .document(user.uid)
        .collection('categories')
        .document(task.category);

    // check whether the task is split over two days (e.g., sleep)
    if (task.timeStart.day != task.timeEnd.day) {
      var taskData1 = {
        'time_start': task.timeStart,
        'time_end': DateTime(task.timeStart.year, task.timeStart.month,
            task.timeStart.day, 23, 59, 59, 59, 59),
        'record_start': task.recordStart,
        'record_end': task.recordEnd,
        'name': task.name,
        'notes': task.notes,
        'category': categoryRef,
        'alert_set': task.alertSet,
      };

      var taskData2 = {
        'time_start':
            DateTime(task.timeEnd.year, task.timeEnd.month, task.timeEnd.day),
        'time_end': task.timeEnd,
        'record_start': task.recordStart,
        'record_end': task.recordEnd,
        'name': task.name,
        'notes': task.notes,
        'category': categoryRef,
        'alert_set': task.alertSet,
      };

      await usersRef
          .document(user.uid)
          .collection('tasks')
          .document(task.id)
          .setData(taskData1, merge: true);
      await usersRef
          .document(user.uid)
          .collection('tasks')
          .document()
          .setData(taskData2, merge: true);
    } else {
      var taskData = {
        'time_start': task.timeStart,
        'time_end': task.timeEnd,
        'record_start': task.recordStart,
        'record_end': task.recordEnd,
        'name': task.name,
        'notes': task.notes,
        'category': categoryRef,
        'alert_set': task.alertSet,
      };

      await usersRef
          .document(user.uid)
          .collection('tasks')
          .document(task.id)
          .setData(taskData, merge: true);
    }
  }
}

Future<void> saveRecording(taskID, recordStart, recordEnd, user) async {
  final CollectionReference usersRef = Firestore.instance.collection('users');
  final snapShot = await usersRef.document(user.uid).get();

  if (snapShot.exists) {
    var taskData = {
      'record_start': recordStart,
      'record_end': recordEnd,
    };

    await usersRef
        .document(user.uid)
        .collection('tasks')
        .document(taskID)
        .setData(taskData, merge: true);
  }
}

Future<void> saveAlertBool(taskID, user, alertSet) async {
  final CollectionReference usersRef = Firestore.instance.collection('users');
  final snapShot = await usersRef.document(user.uid).get();

  if (snapShot.exists) {
    var taskData = {'alert_set': alertSet};

    await usersRef
        .document(user.uid)
        .collection('tasks')
        .document(taskID)
        .setData(taskData, merge: true);
  }
}

Future<List<dynamic>> getCategories(user) async {
  final CollectionReference usersRef = Firestore.instance.collection('users');
  final snapShot = await usersRef.document(user.uid).get();

  if (snapShot.exists) {
    final QuerySnapshot result = await usersRef
        .document(user.uid)
        .collection('categories')
        .getDocuments();

    return result.documents;
  }

  return [];
}

Future<bool> isOverlapPartial(user, timeField, timeStart, timeEnd) async {
  final CollectionReference usersRef = Firestore.instance.collection('users');
  final snapShot = await usersRef.document(user.uid).get();

  if (snapShot.exists) {
    final QuerySnapshot result = await usersRef
        .document(user.uid)
        .collection('tasks')
        .where(timeField, isGreaterThan: timeStart)
        .where(timeField, isLessThan: timeEnd)
        .getDocuments();

    return result.documents.iterator.moveNext();
  }

  return false;
}

Future<bool> isOverlapComplete(user, timeStart, timeEnd) async {
  final CollectionReference usersRef = Firestore.instance.collection('users');
  final snapShot = await usersRef.document(user.uid).get();

  if (snapShot.exists) {
    final QuerySnapshot result = await usersRef
        .document(user.uid)
        .collection('tasks')
        .where('time_end', isGreaterThan: timeEnd)
        .getDocuments();

    DocumentSnapshot overlappingDocument = result.documents.singleWhere(
        (document) => document['time_start'].toDate().isBefore(timeStart));
    return overlappingDocument.exists;
  }

  return false;
}
