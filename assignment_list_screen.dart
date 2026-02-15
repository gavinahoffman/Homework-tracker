import 'package:flutter/material.dart';
import '../presenters/assignment_presenter.dart';
import '../models/assignment_model.dart';

class AssignmentListScreen extends StatefulWidget {
  const AssignmentListScreen({super.key});

  @override
  State<AssignmentListScreen> createState() =>
      _AssignmentListScreenState();
}

class _AssignmentListScreenState
    extends State<AssignmentListScreen> {

  late AssignmentPresenter presenter;
  List<Assignment> assignments = [];
  final TextEditingController _controller =
      TextEditingController();

  @override
  void initState() {
    super.initState();

    presenter = AssignmentPresenter(
      AssignmentModel(),
      onAssignmentsLoaded: (loadedAssignments) {
        setState(() {
          assignments = loadedAssignments;
        });
      },
    );

    presenter.loadAssignments();
  }

  void _addAssignment() async {
    if (_controller.text.isNotEmpty) {
      await presenter.addAssignment(_controller.text);
      _controller.clear();
      await presenter.loadAssignments();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Assignments')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      labelText: 'New Assignment',
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _addAssignment,
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: assignments.length,
              itemBuilder: (context, index) {
                final assignment = assignments[index];

                return CheckboxListTile(
                  title: Text(
                    assignment.title,
                    style: TextStyle(
                      decoration: assignment.isCompleted
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                    ),
                  ),
                  value: assignment.isCompleted,
                  onChanged: (_) async {
                    await presenter.toggleAssignment(index);
                    await presenter.loadAssignments();
                  },
                );
              },
