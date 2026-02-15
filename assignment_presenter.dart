import '../models/assignment_model.dart';

class AssignmentPresenter {
  final AssignmentModel model;
  final Function(List<Assignment>) onAssignmentsLoaded;

  AssignmentPresenter(
    this.model, {
    required this.onAssignmentsLoaded,
  });

  Future<void> loadAssignments() async {
    final assignments = await model.loadAssignments();
    onAssignmentsLoaded(assignments);
  }

  Future<void> addAssignment(String title) async {
    await model.addAssignment(title);
  }

  Future<void> toggleAssignment(int index) async {
    await model.toggleAssignment(index);
  }
}
