import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/task.dart';
import '../services/storage_service.dart';

class TaskProvider with ChangeNotifier {
  final List<Task> _tasks = [];
  final _uuid = const Uuid();
  final _storageService = StorageService();
  bool _isLoading = true;

  List<Task> get tasks => _tasks;
  bool get isLoading => _isLoading;

  TaskProvider() {
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    try {
      _isLoading = true;
      notifyListeners();
      
      final loadedTasks = await _storageService.loadTasks();
      _tasks.clear();
      _tasks.addAll(loadedTasks);
    } catch (e) {
      print('Error loading tasks: $e');
      // Keep empty list if loading fails
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _saveTasks() async {
    try {
      await _storageService.saveTasks(_tasks);
    } catch (e) {
      print('Error saving tasks: $e');
      // Don't throw error to prevent app crash
    }
  }

  Future<void> addTask(String title, String description, DateTime dueDate) async {
    Task? newTask;
    try {
      newTask = Task(
        id: _uuid.v4(),
        title: title,
        description: description,
        dueDate: dueDate,
      );
      _tasks.add(newTask);
      await _saveTasks();
      notifyListeners();
    } catch (e) {
      print('Error adding task: $e');
      // Remove the task if saving fails
      if (newTask != null) {
        _tasks.removeWhere((t) => t.id == newTask!.id);
        notifyListeners();
      }
    }
  }

  Future<void> updateTask(Task task) async {
    try {
      final index = _tasks.indexWhere((t) => t.id == task.id);
      if (index != -1) {
        _tasks[index] = task;
        await _saveTasks();
        notifyListeners();
      }
    } catch (e) {
      print('Error updating task: $e');
    }
  }

  Future<void> deleteTask(String taskId) async {
    try {
      _tasks.removeWhere((task) => task.id == taskId);
      await _saveTasks();
      notifyListeners();
    } catch (e) {
      print('Error deleting task: $e');
    }
  }

  Future<void> addMilestone(String taskId, String title) async {
    try {
      final taskIndex = _tasks.indexWhere((t) => t.id == taskId);
      if (taskIndex != -1) {
        final milestone = Milestone(
          id: _uuid.v4(),
          title: title,
        );
        _tasks[taskIndex].milestones.add(milestone);
        await _saveTasks();
        notifyListeners();
      }
    } catch (e) {
      print('Error adding milestone: $e');
    }
  }

  Future<void> updateMilestone(String taskId, String milestoneId, {String? title, bool? isCompleted}) async {
    try {
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
          await _saveTasks();
          notifyListeners();
        }
      }
    } catch (e) {
      print('Error updating milestone: $e');
    }
  }

  Future<void> deleteMilestone(String taskId, String milestoneId) async {
    try {
      final taskIndex = _tasks.indexWhere((t) => t.id == taskId);
      if (taskIndex != -1) {
        _tasks[taskIndex].milestones.removeWhere((m) => m.id == milestoneId);
        await _saveTasks();
        notifyListeners();
      }
    } catch (e) {
      print('Error deleting milestone: $e');
    }
  }
} 