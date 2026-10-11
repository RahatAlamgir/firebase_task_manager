import 'package:firebase_task_manager/widgets/task_list_styles.dart';
import 'package:flutter/material.dart';

class TaskListEmptyState extends StatelessWidget {
  const TaskListEmptyState({super.key, required this.hasAnyTasks});

  final bool hasAnyTasks;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.check_circle_outline_rounded,
              size: 42,
              color: Color(0xFFB7C1D0),
            ),
            const SizedBox(height: 12),
            Text(
              hasAnyTasks ? 'No tasks in this list' : 'No tasks yet',
              style: const TextStyle(
                color: TaskListStyles.ink,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 5),
            const Text(
              'Add a task to get started.',
              textAlign: TextAlign.center,
              style: TextStyle(color: TaskListStyles.muted, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class TaskListError extends StatelessWidget {
  const TaskListError({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          'Could not load tasks\n$message',
          textAlign: TextAlign.center,
          style: const TextStyle(color: TaskListStyles.muted),
        ),
      ),
    );
  }
}
