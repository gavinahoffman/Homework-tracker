import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class Assignment {
  final String title;
  bool isCompleted;

  Assignment({
    required this.title,
    this.isCompleted = false,
  });

  factory Assignment.fromMap(Map<dynamic, dynamic> data) {
    return Assignment(
      title: data['title'] ?? '',
      isCompleted: data['isCompleted'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'isCompleted': isCompleted,
    };
  }
}

class AssignmentModel {
  final FirebaseDatabase _db = FirebaseDatabase.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<List<Assignment>> loadAssignments() async {
    final user = _auth.currentUser;
    if (user == null) return [];

    final snapshot =
        await _db.ref("assignments/${user.uid}").once();

    if (snapshot.snapshot.value == null) return [];

    final data =
        snapshot.snapshot.value as Map<dynamic, dynamic>;

    return data.values
        .map((item) => Assignment.fromMap(item))
        .toList();
  }

  Future<void> addAssignment(String title) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final assignment = Assignment(title: title);

    await _db
        .ref("assignments/${user.uid}")
        .push()
        .set(assignment.toMap());
  }

  Future<void> toggleAssignment(int index) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final ref = _db.ref("assignments/${user.uid}");
    final snapshot = await ref.once();

    if (snapshot.snapshot.value == null) return;

    final data =
        snapshot.snapshot.value as Map<dynamic, dynamic>;

    final keys = data.keys.toList();

    final selectedKey = keys[index];
    final currentValue =
        data[selectedKey]['isCompleted'] ?? false;

    await ref.child(selectedKey).update({
      'isCompleted': !currentValue,
    });
  }
}
