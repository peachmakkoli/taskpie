import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:suncircle/screens/category/categoryform.dart';
import 'package:suncircle/screens/category/deletecategory.dart';

Widget categoryListSheet(FirebaseUser user, ScrollController scrollController) {
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
              return Card(
                color: _getColor(_categories[index]),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16, 8, 8, 8),
                  child: Row(
                    children: <Widget>[
                      Text(
                        _categories[index].documentID,
                      ),
                      Spacer(),
                      ButtonBar(
                        children: <Widget>[
                          IconButton(
                            tooltip: 'Edit category',
                            icon: Icon(
                              Icons.create,
                              size: 30,
                            ),
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) {
                                    return CategoryForm(
                                      title: 'TaskPie',
                                      subtitle: 'Update Task',
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

Color _getColor(category) {
  return Color(int.parse('0x${category['color']}'));
}
