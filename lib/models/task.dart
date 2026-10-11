import 'package:cloud_firestore/cloud_firestore.dart';

class Task {
  final String id;
  final String title;
  final String content;
  final String date;
  final String course;
  final String priority;
  final bool status;

  Task({
    required this.id,
    required this.title,
    required this.content,
    required this.date,
    required this.course,
    required this.priority,
    required this.status,
  });

  factory Task.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return Task(
      id: doc.id,
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      date: data['date'] ?? '',
      course: data['course'] ?? '',
      priority: data['priority'] ?? 'low',
      status: data['status'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'content': content,
      'date': date,
      'course': course,
      'priority': priority,
      'status': status,
    };
  }
}
