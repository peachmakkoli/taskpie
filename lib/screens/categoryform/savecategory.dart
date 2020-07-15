import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> saveCategory(category, user) async {
  final CollectionReference usersRef = Firestore.instance.collection('users');
  final snapShot = await usersRef.document(user.uid).get();

  if (snapShot.exists) {
    var categoryData = {
      'color': category.color,
    };

    await usersRef
        .document(user.uid)
        .collection('categories')
        .document(category.name.toLowerCase())
        .setData(categoryData);
  }
}

Future<String> checkUnique(name, user) async {
  final CollectionReference usersRef = Firestore.instance.collection('users');
  final snapShot = await usersRef
      .document(user.uid)
      .collection('categories')
      .document(name.toLowerCase())
      .get();

  if (snapShot.exists) return snapShot.documentID;
  return '';
}
