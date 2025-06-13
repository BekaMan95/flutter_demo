import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/task.dart';

class TaskProvider with ChangeNotifier {
  final List<Task> _tasks = [];
  final _uuid = const Uuid();

  List<Task> get tasks => _tasks;

  void addTask(String title, String description, DateTime dueDate) {
    final task = Task(
      id: _uuid.v4(),
      title: title,
      description: description,
      dueDate: dueDate,
    );
    _tasks.add(task);
    notifyListeners();
  }

  void updateTask(Task task) {
    final index = _tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      _tasks[index] = task;
      notifyListeners();
    }
  }

  void deleteTask(String taskId) {
    _tasks.removeWhere((task) => task.id == taskId);
    notifyListeners();
  }

  void addMilestone(String taskId, String title) {
    final taskIndex = _tasks.indexWhere((t) => t.id == taskId);
    if (taskIndex != -1) {
      final milestone = Milestone(
        id: _uuid.v4(),
        title: title,
      );
      _tasks[taskIndex].milestones.add(milestone);
      notifyListeners();
    }
  }

  void updateMilestone(String taskId, String milestoneId, {String? title, bool? isCompleted}) {
    final taskIndex = _tasks.indexWhere((t) => t.id == taskId);
    if (taskIndex != -1) {
      final milestoneIndex = _tasks[taskIndex].milestones.indexWhere((m) => m.id == milestoneId);
      if (milestoneIndex != -1) {
        if (title != null) {
          _tasks[taskIndex].milestones[milestoneIndex].title = title;
        }
        if (isCompleted != null) {
          _tasks[taskIndex].milestones[milestoneIndex].isCompleted = isCompleted;
        }
        notifyListeners();
      }
    }
  }

  void deleteMilestone(String taskId, String milestoneId) {
    final taskIndex = _tasks.indexWhere((t) => t.id == taskId);
    if (taskIndex != -1) {
      _tasks[taskIndex].milestones.removeWhere((m) => m.id == milestoneId);
      notifyListeners();
    }
  }
} 