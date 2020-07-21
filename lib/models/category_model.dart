import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

class CategoryModel {
  CategoryModel(this.name, this.color);
  String name;
  String color;

  static Color getColor(DocumentSnapshot category) {
    return Color(int.parse('0x${category['color']}'));
  }
}
