import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:taskpie/models/category_model.dart';
import 'package:taskpie/screens/category/category_form.dart';
import 'package:taskpie/services/category/delete_category.dart';

class CategoryListSheet extends StatelessWidget {
  const CategoryListSheet({Key key, this.user}) : super(key: key);

  final FirebaseUser user;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance
            .collection('users')
            .document(user.uid)
            .collection('categories')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return Container(
                height: MediaQuery.of(context).size.height,
                alignment: Alignment(0.0, 0.0),
                child: Text('Baking...'));
          List<DocumentSnapshot> _categories = snapshot.data.documents;
          return ListView.builder(
            padding: EdgeInsets.fromLTRB(24, 16, 24, 16),
            itemCount: _categories.length,
            itemBuilder: (BuildContext context, int index) {
              var _categoryColor = CategoryModel.getColor(_categories[index]);
              var _adaptiveColor = _categoryColor.computeLuminance() > 0.3
                  ? Colors.black
                  : Colors.white;
              return Card(
                color: _categoryColor,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16, 8, 8, 8),
                  child: Row(
                    children: <Widget>[
                      Text(
                        _categories[index].documentID,
                        style: TextStyle(color: _adaptiveColor, fontSize: 16.0),
                      ),
                      Spacer(),
                      ButtonBar(
                        children: <Widget>[
                          IconButton(
                            tooltip: 'Edit category',
                            icon: Icon(
                              Icons.create,
                              size: 30,
                              color: _adaptiveColor,
                            ),
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) {
                                    return CategoryForm(
                                      title: 'TaskPie',
                                      subtitle: 'Update Category',
                                      user: user,
                                      category: CategoryModel(
                                          _categories[index].documentID,
                                          _categories[index]['color']),
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                          IconButton(
                            tooltip: 'Delete category',
                            icon: Icon(
                              Icons.delete_outline,
                              size: 30,
                              color: _adaptiveColor,
                            ),
                            onPressed: () {
                              showDeleteCategoryAlert(
                                  context, _categories[index].documentID, user);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        });
  }
}
