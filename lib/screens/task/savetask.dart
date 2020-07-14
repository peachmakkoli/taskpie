import 'package:cloud_firestore/cloud_firestore.dart';


Future<void> saveTask(task, user) async {
  final CollectionReference usersRef = Firestore.instance.collection('users');
  final snapShot = await usersRef.document(user.uid).get();

  // check whether the task is split over two days (e.g., sleep)
  if (task.timeStart.day != task.timeEnd.day) {
    var taskData1 = {
      'time_start': task.timeStart,
      'time_end': DateTime(task.timeStart.year, task.timeStart.month, task.timeStart.day, 23, 59, 59, 59, 59),
      'name': task.name,
      'notes': task.notes,
    };

    var taskData2 = {
      'time_start': DateTime(task.timeEnd.year, task.timeEnd.month, task.timeEnd.day),
      'time_end': task.timeEnd,
      'name': task.name,
      'notes': task.notes,
    }; 

    await usersRef.document(user.uid).collection('tasks').document(task.id).setData(taskData1);
    await usersRef.document(user.uid).collection('tasks').document().setData(taskData2);
  }
  else {
    var taskData = {
      'time_start': task.timeStart,
      'time_end': task.timeEnd,
      'name': task.name,
      'notes': task.notes,
    };

    await usersRef.document(user.uid).collection('tasks').document(task.id).setData(taskData);
  }
}
