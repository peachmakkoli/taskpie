import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:suncircle/models/category_model.dart';
import 'package:suncircle/screens/category/category_form.dart';
import 'package:suncircle/services/category/delete_category.dart';

Widget categoryListSheet(FirebaseUser user, ScrollController scrollController) {
  Color _getColor(category) {
    return Color(int.parse('0x${category['color']}'));
  }

  return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance
          .collection('users')
          .document(user.uid)
          .collection('categories')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return Text('Loading data...');
        List<DocumentSnapshot> _categories = snapshot.data.documents;
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
                topRight: Radius.circular(30), topLeft: Radius.circular(30)),
            boxShadow: [
              BoxShadow(
                  color: Colors.grey,
                  offset: Offset(1.0, -2.0),
                  blurRadius: 4.0,
                  spreadRadius: 2.0)
            ],
            color: Colors.white,
          ),
          child: ListView.builder(
            padding: EdgeInsets.fromLTRB(24, 16, 24, 16),
            controller: scrollController,
            itemCount: _categories.length + 1,
            itemBuilder: (BuildContext context, int index) {
              if (index == 0) {
                return Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(24, 16, 24, 48),
                    child: Text(
                      'Categories',
                      style: Theme.of(context).textTheme.headline6,
                    ),
                  ),
                );
              }
              index -= 1;
              var _categoryColor = _getColor(_categories[index]);
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
                        style: TextStyle(color: _adaptiveColor),
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
          ),
        );
      });
}
