import 'package:flutter/material.dart';
import '../presenters/course_presenter.dart';
import '../models/course_model.dart';

class CourseListScreen extends StatefulWidget {
  const CourseListScreen({super.key});

  @override
  State<CourseListScreen> createState() => _CourseListScreenState();
}

class _CourseListScreenState extends State<CourseListScreen> {
  late CoursePresenter presenter;
  List<Course> courses = [];

  @override
  void initState() {
    super.initState();

    presenter = CoursePresenter(
      CourseModel(),
      onCoursesLoaded: (loadedCourses) {
        setState(() {
          courses = loadedCourses;
        });
      },
    );

    presenter.loadCourses();
  }

  void _showAddCourseDialog() {
    final nameController = TextEditingController();
    final descController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add Course'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration:
                  const InputDecoration(labelText: 'Course Name'),
            ),
            TextField(
              controller: descController,
              decoration: const InputDecoration(
                  labelText: 'Description (optional)'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isNotEmpty) {
                await presenter.addCourse(
                  nameController.text,
                  descController.text,
                );
                await presenter.loadCourses();
                Navigator.pop(context);
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
      body: ListView.builder(
        itemCount: courses.length,
        itemBuilder: (context, index) {
          final course = courses[index];

          return ListTile(
            title: Text(course.name),
            subtitle:
                course.description != null &&
                        course.description!.isNotEmpty
                    ? Text(course.description!)
                    : null,
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddCourseDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
