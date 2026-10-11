import 'package:firebase_task_manager/screens/notification/notification_detail.dart';

import 'package:flutter/material.dart';

class AppNavigator {
  static final GlobalKey<NavigatorState> key = GlobalKey<NavigatorState>();

  static void openDetails(String payload) {
    key.currentState?.push(
      MaterialPageRoute(
        builder: (context) => NotificationDetailPage(
          title: 'Notification',
          body: payload,
          source: NotificationSource.local,
        ),
      ),
    );
  }
}
