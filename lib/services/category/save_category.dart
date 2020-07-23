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
  if (name == originalName && action == 'Update Category')
    return ''; // allows users to update existing category colors

  final CollectionReference usersRef = Firestore.instance.collection('users');
  final snapShot =
      await usersRef.document(user.uid).collection('categories').getDocuments();

  final DocumentSnapshot _category =
      snapShot.documents.singleWhere((document) => document.documentID == name);

  if (_category.exists) return name;
  return '';
}
