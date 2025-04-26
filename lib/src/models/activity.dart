import 'package:flutter/material.dart';

/// Model simplu pentru o activitate de calendar,
/// cu un flag pentru bifare (done/undone).
class Activity {
  final String title;
  final Color color;
  bool isDone;              // <- adaugă acest câmp

  Activity({
    required this.title,
    required this.color,
    this.isDone = false,     // inițial false
  });
}
