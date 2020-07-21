import 'package:flutter/material.dart';

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
}
