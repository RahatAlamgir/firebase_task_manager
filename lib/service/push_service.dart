import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_task_manager/others/app_navigator.dart';
import 'package:firebase_task_manager/service/notification_service.dart';
import 'package:flutter/material.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint('Background FCM message: ${message.messageId} ${message.data}');
}

class PushService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  static final ValueNotifier<List<RemoteMessage>> foreGroundMessage =
      ValueNotifier<List<RemoteMessage>>([]);

  static Future<void> init() async {
    final settings = await _messaging.requestPermission(
      sound: true,
      alert: true,
      badge: true,
    );

    debugPrint('Notification permission: ${settings.authorizationStatus}');

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      debugPrint('Foreground FCM: ${message.messageId} ${message.data}');
      foreGroundMessage.value = [...foreGroundMessage.value, message];

      final notification = message.notification;
      if (notification != null) {
        await NotificationService.showNow(
          id:
              message.messageId?.hashCode ??
              DateTime.now().millisecondsSinceEpoch ~/ 1000,
          title: notification.title ?? 'Notification',
          body: notification.body ?? '',
          payload: jsonEncode({
            'title': notification.title ?? 'Notification',
            'body': notification.body ?? '',
            'messageId': message.messageId,
            'data': message.data,
            'source': 'push',
          }),
        );
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen(_openFromMessage);
    await getToken();
  }

  static Future<void> handleLaunchMessage() async {
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _openFromMessage(initialMessage);
    }
  }

  // static void _openFromMessage(RemoteMessage remote) {
  //   AppNavigator.openDetails(remote.data['screen']?.toString() ?? 'push');
  // }

  static void _openFromMessage(RemoteMessage remote) {
    AppNavigator.openDetails(
      jsonEncode({
        'title': remote.notification?.title ?? 'Notification',
        'body': remote.notification?.body ?? '',
        'messageId': remote.messageId,
        'data': remote.data,
        'source': 'push',
      }),
    );
  }

  static Future<String?> getToken() async {
    final token = await _messaging.getToken();
    debugPrint('FCM Token: $token');
    return token;
  }
}
