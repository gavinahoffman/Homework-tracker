import 'package:flutter/material.dart';
import '../presenters/course_presenter.dart';
import '../models/models/course_model.dart';
import '../widgets/add_fab.dart';

class CourseListScreen extends StatefulWidget {
  const CourseListScreen({super.key});

  @override
  State<CourseListScreen> createState() => _CourseListScreenState();
}

class _CourseListScreenState extends State<CourseListScreen> {
  final CoursePresenter _presenter = CoursePresenter();
  List<Course> _courses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCourses();
  }

  Future<void> _loadCourses() async {
    setState(() => _isLoading = true);
    final courses = await _presenter.loadCourses();
    setState(() {
      _courses = courses;
      _isLoading = false;
    });
  }

  void _showAddCourseDialog() {
    String courseName = '';
    String courseDescription = '';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Course'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              autofocus: true,
              decoration: const InputDecoration(hintText: 'Course name'),
              onChanged: (value) => courseName = value,
            ),
            const SizedBox(height: 8),
            TextField(
              decoration: const InputDecoration(
                  hintText: 'Description (optional)'),
              onChanged: (value) => courseDescription = value,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (courseName.trim().isNotEmpty) {
                Navigator.pop(context);
                await _presenter.addCourse(
                  courseName.trim(),
                  description: courseDescription.trim().isEmpty
                      ? null
                      : courseDescription.trim(),
                );
                await _loadCourses();
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Courses')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _courses.isEmpty
              ? const Center(
                  child: Text('No courses yet. Tap + to add one!'))
              : ListView.builder(
                  itemCount: _courses.length,
                  itemBuilder: (context, index) {
                    final course = _courses[index];
                    return ListTile(
                      leading:
                          const Icon(Icons.book, color: Colors.blue),
                      title: Text(course.name),
                      subtitle: (course.description != null &&
                              course.description!.isNotEmpty)
                          ? Text(course.description!)
                          : null,
                      trailing: IconButton(
                        icon:
                            const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          await _presenter.deleteCourse(course.name);
                          await _loadCourses();
                        },
                      ),
                    );
                  },
                ),
      floatingActionButton: AddFAB(
        onPressed: _showAddCourseDialog,
        tooltip: 'Add Course',
      ),
    );
  }
}
