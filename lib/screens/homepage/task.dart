import 'package:flutter/material.dart';

class Task {
  Task(this.name, this.notes, this.time_start, this.time_end);
  final String name;
  final String notes;
  final DateTime time_start;
  final DateTime time_end;

  Duration get duration => time_end.difference(time_start);

  // Source: https://stackoverflow.com/a/54775297
  String _printDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }
}
