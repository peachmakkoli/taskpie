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
        .setData(categoryData, merge: true);
  }
}

Future<String> checkUnique(name, originalName, user, action) async {
  if (name == originalName && action == 'Update Task')
    return ''; // allows users to update existing category colors

  final CollectionReference usersRef = Firestore.instance.collection('users');
  final snapShot =
      await usersRef.document(user.uid).collection('categories').getDocuments();

  bool found = false;
  snapShot.documents.forEach((doc) {
    if (doc.documentID == name) found = true;
  });

  if (found) return name;
  return '';
}
