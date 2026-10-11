import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_task_manager/models/task.dart';

class TaskService {
  final CollectionReference<Map<String, dynamic>> _notes = FirebaseFirestore
      .instance
      .collection('notes');

  Future<void> addTask({
    required String title,
    required String content,
    required String date,
    required String course,
    required String priority,
    bool status = false,
  }) async {
    await _notes.add({
      'title': title,
      'content': content,
      'date': date,
      'course': course,
      'priority': priority,
      'status': status,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<Task>> getNotes() {
    return _notes.snapshots().map(
      (snapshot) => snapshot.docs.map((doc) => Task.fromDoc(doc)).toList(),
    );
  }

  Future<void> updateTask({
    required String id,
    required String title,
    required String content,
    required String date,
    required String course,
    required String priority,
    required bool status,
  }) async {
    await _notes.doc(id).update({
      'title': title,
      'content': content,
      'date': date,
      'course': course,
      'priority': priority,
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteNote(String id) async {
    await _notes.doc(id).delete();
  }
}
