import 'package:firebase_task_manager/models/task.dart';
import 'package:firebase_task_manager/widgets/small_action.dart';
import 'package:firebase_task_manager/widgets/task_list_styles.dart';
import 'package:flutter/material.dart';

class TaskCard extends StatelessWidget {
  const TaskCard({
    super.key,
    required this.task,
    required this.onTap,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  final Task task;
  final VoidCallback onTap;
  final ValueChanged<bool> onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final completed = task.status;
    final priority = task.priority.toString().toLowerCase();
    final isHigh = priority.contains('high');
    final isLow = priority.contains('low');
    final priorityLabel = isHigh ? 'High' : (isLow ? 'Low' : 'Medium');
    final priorityColor = isHigh
        ? const Color(0xFFEF5264)
        : (isLow ? const Color(0xFF8493A8) : const Color(0xFFEAA13A));
    final priorityBackground = isHigh
        ? const Color(0xFFFFEEF0)
        : (isLow ? const Color(0xFFF0F3F7) : const Color(0xFFFFF5E5));

    return Opacity(
      opacity: completed ? 0.72 : 1,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.fromLTRB(12, 12, 10, 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE9EEF4)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x080D1B2A),
                  blurRadius: 12,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 1),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: () => onToggle(!completed),
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: completed
                            ? const Color(0xFF6C7687)
                            : Colors.white,
                        border: Border.all(
                          color: completed
                              ? const Color(0xFF6C7687)
                              : const Color(0xFFD8E0EA),
                          width: 2,
                        ),
                      ),
                      child: completed
                          ? const Icon(
                              Icons.check,
                              size: 13,
                              color: Colors.white,
                            )
                          : null,
                    ),
                  ),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 6,
                        runSpacing: 5,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: priorityBackground,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 5,
                                  height: 5,
                                  decoration: BoxDecoration(
                                    color: priorityColor,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  priorityLabel,
                                  style: TextStyle(
                                    color: priorityColor,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (completed)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE7F8F1),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: const Text(
                                'Done',
                                style: TextStyle(
                                  color: Color(0xFF42A987),
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 7),
                      Text(
                        task.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: TaskListStyles.ink,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          decoration: completed
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        task.content.trim().isNotEmpty
                            ? task.content
                            : task.course,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: TaskListStyles.muted,
                          fontSize: 10,
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 9),
                      Container(height: 1, color: const Color(0xFFF0F3F7)),
                      const SizedBox(height: 7),
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_today_outlined,
                            size: 10,
                            color: Color(0xFF9AA6B7),
                          ),
                          const SizedBox(width: 5),
                          Flexible(
                            child: Text(
                              'Due ${task.date}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Color(0xFF7F8CA0),
                                fontSize: 9,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Icon(
                            Icons.access_time_rounded,
                            size: 11,
                            color: Color(0xFF9AA6B7),
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              task.course,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Color(0xFF7F8CA0),
                                fontSize: 9,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 2),
                Column(
                  children: [
                    SmallActions(
                      icon: Icons.edit_outlined,
                      tooltip: 'Edit task',
                      onPressed: onEdit,
                    ),
                    SmallActions(
                      icon: Icons.delete_outline_rounded,
                      tooltip: 'Delete task',
                      onPressed: onDelete,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
