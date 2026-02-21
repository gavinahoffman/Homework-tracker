import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/auth_service.dart';

class Assignment {
  String title;
  bool isCompleted;
  String courseName;

  Assignment({
    required this.title,
    this.isCompleted = false,
    this.courseName = '',
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'isCompleted': isCompleted,
        'courseName': courseName,
      };

  factory Assignment.fromJson(Map<String, dynamic> json) => Assignment(
        title: json['title'] ?? '',
        isCompleted: json['isCompleted'] ?? false,
        courseName: json['courseName'] ?? '',
      );
}

class AssignmentModel {
  Future<String> _getKey() async {
    final email = await AuthService().getCurrentUserEmail();
    return 'assignments_${email ?? 'guest'}';
  }

  Future<List<Assignment>> fetchAssignments() async {
    final prefs = await SharedPreferences.getInstance();
    final key = await _getKey();
    final data = prefs.getStringList(key) ?? [];
    return data
        .map((s) => Assignment.fromJson(jsonDecode(s)))
        .toList();
  }

  Future<void> saveAssignments(List<Assignment> assignments) async {
    final prefs = await SharedPreferences.getInstance();
    final key = await _getKey();
    final data = assignments.map((a) => jsonEncode(a.toJson())).toList();
    await prefs.setStringList(key, data);
  }

  Future<void> addAssignment(String title, String courseName) async {
    final assignments = await fetchAssignments();
    assignments.add(Assignment(title: title, courseName: courseName));
    await saveAssignments(assignments);
  }

  Future<void> toggleCompleted(int index) async {
    final assignments = await fetchAssignments();
    if (index >= assignments.length) return;
    assignments[index].isCompleted = !assignments[index].isCompleted;
    await saveAssignments(assignments);
  }

  Future<void> deleteAssignment(int index) async {
    final assignments = await fetchAssignments();
    if (index >= assignments.length) return;
    assignments.removeAt(index);
    await saveAssignments(assignments);
  }

  Future<void> updateAssignmentTitle(int index, String newTitle) async {
    final assignments = await fetchAssignments();
    if (index >= assignments.length) return;
    assignments[index].title = newTitle;
    await saveAssignments(assignments);
  }
}
