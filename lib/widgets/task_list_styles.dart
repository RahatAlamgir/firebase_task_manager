import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_task_manager/screens/notification/notification_page.dart';
import 'package:flutter/material.dart';

class TaskListStyles {
  static const Color page = Color(0xFFF5F7FA);
  static const Color ink = Color(0xFF172033);
  static const Color muted = Color(0xFF8290A5);
  static const Color line = Color(0xFFE8EDF3);
}

class TaskListHeader extends StatelessWidget {
  const TaskListHeader({
    super.key,
    required this.totalCount,
    required this.onShowAll,
  });

  final int totalCount;
  final VoidCallback onShowAll;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tasks',
                  style: TextStyle(
                    color: TaskListStyles.ink,
                    fontSize: 25,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.7,
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE9EDF4),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '$totalCount TOTAL',
                        style: const TextStyle(
                          color: Color(0xFF596579),
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(width: 7),
                    const Flexible(
                      child: Text(
                        'Your task overview',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: TaskListStyles.muted,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Signout',

            onPressed: () async {
              await FirebaseAuth.instance.signOut();
            },
            icon: const Icon(
              Icons.logout,
              color: TaskListStyles.muted,
              size: 23,
            ),
          ),
          IconButton(
            tooltip: 'Notification',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NotificationPage()),
              );
            },
            icon: const Icon(
              Icons.notifications,
              color: TaskListStyles.ink,
              size: 21,
            ),
          ),
        ],
      ),
    );
  }
}
