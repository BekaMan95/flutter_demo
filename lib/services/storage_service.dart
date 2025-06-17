import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/task.dart';

class StorageService {
  static const String _fileName = 'tasks.json';

  Future<String> get _localPath async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      return directory.path;
    } catch (e) {
      print('Error getting documents directory: $e');
      // Fallback to temporary directory
      final tempDir = await getTemporaryDirectory();
      return tempDir.path;
    }
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/$_fileName');
  }

  Future<List<Task>> loadTasks() async {
    try {
      final file = await _localFile;
      if (!await file.exists()) {
        return [];
      }

      final contents = await file.readAsString();
      if (contents.isEmpty) {
        return [];
      }

      final List<dynamic> jsonList = json.decode(contents);
      
      return jsonList.map((json) => _taskFromJson(json)).toList();
    } catch (e) {
      print('Error loading tasks: $e');
      return [];
    }
  }

  Future<void> saveTasks(List<Task> tasks) async {
    try {
      final file = await _localFile;
      final jsonList = tasks.map((task) => _taskToJson(task)).toList();
      final jsonString = json.encode(jsonList);
      await file.writeAsString(jsonString);
    } catch (e) {
      print('Error saving tasks: $e');
      rethrow; // Let the provider handle the error
    }
  }

  Map<String, dynamic> _taskToJson(Task task) {
    return {
      'id': task.id,
      'title': task.title,
      'description': task.description,
      'isCompleted': task.isCompleted,
      'dueDate': task.dueDate.toIso8601String(),
      'milestones': task.milestones.map((milestone) => {
        'id': milestone.id,
        'title': milestone.title,
        'isCompleted': milestone.isCompleted,
      }).toList(),
    };
  }

  Task _taskFromJson(Map<String, dynamic> json) {
    try {
      return Task(
        id: json['id'] ?? '',
        title: json['title'] ?? '',
        description: json['description'] ?? '',
        isCompleted: json['isCompleted'] ?? false,
        dueDate: DateTime.tryParse(json['dueDate'] ?? '') ?? DateTime.now(),
        milestones: (json['milestones'] as List<dynamic>?)
            ?.map((milestoneJson) => Milestone(
                  id: milestoneJson['id'] ?? '',
                  title: milestoneJson['title'] ?? '',
                  isCompleted: milestoneJson['isCompleted'] ?? false,
                ))
            .toList() ?? [],
      );
    } catch (e) {
      print('Error parsing task from JSON: $e');
      // Return a default task if parsing fails
      return Task(
        id: json['id'] ?? '',
        title: json['title'] ?? 'Corrupted Task',
        description: json['description'] ?? '',
        isCompleted: false,
        dueDate: DateTime.now(),
        milestones: [],
      );
    }
  }
} 