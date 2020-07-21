import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TaskModel {
  TaskModel(
    this.category,
    this.name,
    this.timeStart,
    this.timeEnd,
    this.notes, [
    this.id,
    this.duration,
    this.color,
    this.alertSet,
    this.recordStart,
    this.recordEnd,
  ]);

  final String id;
  String category;
  String name;
  DateTime timeStart;
  DateTime timeEnd;
  String notes;
  final double duration;
  final Color color;
  bool alertSet;
  DateTime recordStart;
  DateTime recordEnd;

  static double getDuration(Timestamp timeEnd, Timestamp timeStart) {
    if (timeEnd == null || timeStart == null) return 0.0;
    return (timeEnd.seconds - timeStart.seconds) / 3600;
  }

  static Color getColor(DocumentSnapshot category) {
    return Color(int.parse('0x${category['color']}'));
  }
}
