import 'package:firebase_task_manager/models/task.dart';
import 'package:firebase_task_manager/screens/tasks/add_task_screen.dart';
import 'package:firebase_task_manager/screens/tasks/update_task_screen.dart';
import 'package:firebase_task_manager/service/task_service.dart';
import 'package:firebase_task_manager/widgets/task_card.dart';
import 'package:firebase_task_manager/widgets/task_empty_state.dart';
import 'package:firebase_task_manager/widgets/task_filter_chip.dart';
import 'package:firebase_task_manager/widgets/task_list_styles.dart';
import 'package:flutter/material.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final TaskService _taskService = TaskService();

  late final Stream<List<Task>> _tasksStream = _taskService.getNotes();

  int _selectedFilter = 0;

  Future<void> _openAddTask() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddTaskScreen()),
    );
  }

  Future<void> _openEditTask(Task task) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => UpdateTaskScreen(task: task)),
    );
  }

  Future<void> _toggleTask(Task task, bool value) async {
    try {
      await _taskService.updateTask(
        id: task.id,
        title: task.title,
        content: task.content,
        date: task.date,
        course: task.course,
        priority: task.priority,
        status: value,
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not update task: $error')));
    }
  }

  Future<void> _confirmDelete(Task task) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete task?'),
        content: Text('“${task.title}” will be permanently deleted.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (shouldDelete != true) return;

    try {
      await _taskService.deleteNote(task.id);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not delete task: $error')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TaskListStyles.page,
      body: SafeArea(
        child: StreamBuilder<List<Task>>(
          stream: _tasksStream,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return TaskListError(message: '${snapshot.error}');
            }

            if (snapshot.connectionState == ConnectionState.waiting &&
                !snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(color: TaskListStyles.ink),
              );
            }

            final allTasks = snapshot.data ?? <Task>[];
            final completedCount = allTasks.where((task) => task.status).length;
            final pendingCount = allTasks.length - completedCount;

            final visibleTasks = allTasks.where((task) {
              return _selectedFilter == 0 ||
                  (_selectedFilter == 1 && !task.status) ||
                  (_selectedFilter == 2 && task.status);
            }).toList();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TaskListHeader(
                  totalCount: allTasks.length,
                  onShowAll: () => setState(() => _selectedFilter = 0),
                ),
                const Divider(height: 1, color: TaskListStyles.line),
                Padding(
                  padding: const EdgeInsets.fromLTRB(22, 16, 22, 16),
                  child: Row(
                    children: [
                      TaskFilterChip(
                        label: 'All',
                        count: allTasks.length,
                        selected: _selectedFilter == 0,
                        onTap: () => setState(() => _selectedFilter = 0),
                      ),
                      const SizedBox(width: 8),
                      TaskFilterChip(
                        label: 'Pending',
                        count: pendingCount,
                        selected: _selectedFilter == 1,
                        onTap: () => setState(() => _selectedFilter = 1),
                      ),
                      const SizedBox(width: 8),
                      TaskFilterChip(
                        label: 'Completed',
                        count: completedCount,
                        selected: _selectedFilter == 2,
                        onTap: () => setState(() => _selectedFilter = 2),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: visibleTasks.isEmpty
                      ? TaskListEmptyState(hasAnyTasks: allTasks.isNotEmpty)
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(22, 0, 22, 100),
                          itemCount: visibleTasks.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final task = visibleTasks[index];
                            return TaskCard(
                              task: task,
                              onTap: () => _openEditTask(task),
                              onToggle: (value) => _toggleTask(task, value),
                              onEdit: () => _openEditTask(task),
                              onDelete: () => _confirmDelete(task),
                            );
                          },
                        ),
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddTask,
        backgroundColor: TaskListStyles.ink,
        foregroundColor: Colors.white,
        elevation: 5,
        icon: const Icon(Icons.add_rounded, size: 19),
        label: const Text(
          'New Task',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
        ),
      ),
    );
  }
}
