import 'package:flutter/foundation.dart';

class Milestone {
  final String id;
  String title;
  bool isCompleted;

  Milestone({
    required this.id,
    required this.title,
    this.isCompleted = false,
  });
}

class Task {
  final String id;
  String title;
  String description;
  bool isCompleted;
  DateTime dueDate;
  List<Milestone> milestones;

  Task({
    required this.id,
    required this.title,
    this.description = '',
    this.isCompleted = false,
    required this.dueDate,
    List<Milestone>? milestones,
  }) : milestones = milestones ?? [];

  double get completionPercentage {
    if (milestones.isEmpty) return isCompleted ? 100 : 0;
    return (milestones.where((m) => m.isCompleted).length / milestones.length) * 100;
  }
} 