import 'package:flutter/material.dart';
import '../presenters/assignment_presenter.dart';
import '../presenters/course_presenter.dart';
import '../models/models/assignment_model.dart';
import '../widgets/add_fab.dart';

class AssignmentListScreen extends StatefulWidget {
  const AssignmentListScreen({super.key});

  @override
  State<AssignmentListScreen> createState() => _AssignmentListScreenState();
}

class _AssignmentListScreenState extends State<AssignmentListScreen> {
  final AssignmentPresenter assignmentPresenter = AssignmentPresenter();
  final CoursePresenter coursePresenter = CoursePresenter();

  List<Assignment> _assignments = [];
  List<String> _courseNames = [];
  String? _selectedCourseFilter;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final assignments = await assignmentPresenter.loadAssignments();
    final courses = await coursePresenter.loadCourses();
    setState(() {
      _assignments = assignments;
      _courseNames = courses.map((c) => c.name).toList();
      _isLoading = false;
    });
  }

  void _showAddAssignmentDialog() {
    String newTitle = '';
    String? selectedCourse =
        _courseNames.isNotEmpty ? _courseNames.first : null;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Add Assignment'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  autofocus: true,
                  decoration:
                      const InputDecoration(hintText: 'Assignment name'),
                  onChanged: (value) => newTitle = value,
                ),
                const SizedBox(height: 12),
                if (_courseNames.isEmpty)
                  const Text(
                    'No courses yet — add a course first!',
                    style: TextStyle(color: Colors.red, fontSize: 12),
                  )
                else
                  DropdownButtonFormField<String>(
                    value: selectedCourse,
                    decoration:
                        const InputDecoration(labelText: 'Select Course'),
                    items: _courseNames
                        .map((name) => DropdownMenuItem(
                              value: name,
                              child: Text(name),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setDialogState(() => selectedCourse = value);
                    },
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
                  if (newTitle.trim().isNotEmpty) {
                    Navigator.pop(context);
                    await assignmentPresenter.addAssignment(
                      newTitle.trim(),
                      selectedCourse ?? '',
                    );
                    await _loadData();
                  }
                },
                child: const Text('Add'),
              ),
            ],
          );
        });
      },
    );
  }

  void _showEditAssignmentDialog(int index) {
    final controller =
        TextEditingController(text: _assignments[index].title);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Assignment'),
        content: TextField(
          controller: controller,
          decoration:
              const InputDecoration(hintText: 'Assignment name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (controller.text.trim().isNotEmpty) {
                Navigator.pop(context);
                await assignmentPresenter.updateAssignmentTitle(
                    index, controller.text.trim());
                await _loadData();
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayed = _selectedCourseFilter == null
        ? _assignments
        : _assignments
            .where((a) => a.courseName == _selectedCourseFilter)
            .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Assignments'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: DropdownButton<String?>(
              value: _selectedCourseFilter,
              hint: const Text('All',
                  style: TextStyle(color: Colors.white)),
              dropdownColor: Colors.blue,
              underline: const SizedBox(),
              icon: const Icon(Icons.filter_list, color: Colors.white),
              items: [
                const DropdownMenuItem<String?>(
                  value: null,
                  child: Text('All Courses',
                      style: TextStyle(color: Colors.white)),
                ),
                ..._courseNames.map(
                  (name) => DropdownMenuItem<String?>(
                    value: name,
                    child: Text(name,
                        style: const TextStyle(color: Colors.white)),
                  ),
                ),
              ],
              onChanged: (value) =>
                  setState(() => _selectedCourseFilter = value),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : displayed.isEmpty
              ? const Center(
                  child: Text('No assignments yet. Tap + to add one!'))
              : ListView.builder(
                  itemCount: displayed.length,
                  itemBuilder: (context, index) {
                    final assignment = displayed[index];
                    final actualIndex = _assignments.indexOf(assignment);
                    return CheckboxListTile(
                      title: Text(
                        assignment.title,
                        style: TextStyle(
                          decoration: assignment.isCompleted
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                          color: assignment.isCompleted
                              ? Colors.grey
                              : Colors.black,
                        ),
                      ),
                      subtitle: assignment.courseName.isNotEmpty
                          ? Text(
                              assignment.courseName,
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.grey),
                            )
                          : null,
                      value: assignment.isCompleted,
                      onChanged: (_) async {
                        await assignmentPresenter
                            .toggleCompleted(actualIndex);
                        await _loadData();
                      },
                      secondary: IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () =>
                            _showEditAssignmentDialog(actualIndex),
                      ),
                    );
                  },
                ),
      floatingActionButton: AddFAB(
        onPressed: _showAddAssignmentDialog,
        tooltip: 'Add Assignment',
      ),
    );
  }
}
