import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_task_manager/service/notification_service.dart';
import 'package:firebase_task_manager/service/push_service.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  String? _token;
  bool _loadingToken = false;
  String? _tokenError;

  @override
  void initState() {
    super.initState();
    _loadToken();
  }

  Future<void> _loadToken() async {
    setState(() {
      _loadingToken = true;
      _tokenError = null;
    });
    try {
      final token = await PushService.getToken();
      if (!mounted) return;
      setState(() => _token = token);
    } catch (error) {
      if (!mounted) return;
      setState(() => _tokenError = error.toString());
    } finally {
      if (mounted) setState(() => _loadingToken = false);
    }
  }

  Future<void> _showLocalNotification() async {
    try {
      await NotificationService.showNow(
        id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title: 'Test notification',
        body: 'Local notifications are working.',
        payload: 'notifications',
      );
      _message('Local notification sent.');
    } catch (error) {
      _message('Could not show notification: $error');
    }
  }

  Future<void> _scheduleNotification() async {
    try {
      await NotificationService.scheduleIn(
        id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title: 'Reminder',
        body: 'This is your scheduled local reminder.',
        delay: const Duration(seconds: 10),
        payload: 'notifications',
      );
      _message('Reminder scheduled for about 10 seconds from now.');
    } catch (error) {
      _message('Could not schedule reminder: $error');
    }
  }

  void _message(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    final messages = PushService.foreGroundMessage.value;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF172033),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SectionCard(
            icon: Icons.notifications_active_outlined,
            title: 'Local notifications',
            subtitle: 'Test an immediate notification or a scheduled reminder.',
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                FilledButton.icon(
                  onPressed: _showLocalNotification,
                  icon: const Icon(Icons.notifications_outlined),
                  label: const Text('Send test'),
                ),
                OutlinedButton.icon(
                  onPressed: _scheduleNotification,
                  icon: const Icon(Icons.schedule_rounded),
                  label: const Text('Remind in 10 sec'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _SectionCard(
            icon: Icons.cloud_outlined,
            title: 'FCM push notifications',
            subtitle: 'Use this device token as the target when testing a push from your trusted server or Firebase tooling.',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_loadingToken)
                  const LinearProgressIndicator()
                else if (_tokenError != null)
                  Text(
                    'Could not get token: $_tokenError',
                    style: const TextStyle(color: Colors.red),
                  )
                else
                  SelectableText(
                    _token?.isNotEmpty == true
                        ? _token!
                        : 'No FCM token available.',
                    style: const TextStyle(fontSize: 12, height: 1.4),
                  ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  children: [
                    OutlinedButton.icon(
                      onPressed: _loadToken,
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Refresh token'),
                    ),
                    if (_token?.isNotEmpty == true)
                      OutlinedButton.icon(
                        onPressed: () async {
                          await Clipboard.setData(ClipboardData(text: _token!));
                          _message('FCM token copied.');
                        },
                        icon: const Icon(Icons.copy_rounded),
                        label: const Text('Copy token'),
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _SectionCard(
            icon: Icons.inbox_outlined,
            title: 'Foreground messages',
            subtitle:
                'FCM messages received while the app is open appear here.',
            trailing: Text(
              '${messages.length}',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            child: messages.isEmpty
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      'No foreground messages received yet.',
                      style: TextStyle(color: Color(0xFF8290A5)),
                    ),
                  )
                : Column(
                    children: messages.reversed.take(20).map((message) {
                      return _MessageTile(message: message);
                    }).toList(),
                  ),
          ),
          const SizedBox(height: 12),
          const _SectionCard(
            icon: Icons.touch_app_outlined,
            title: 'Background and notification taps',
            subtitle: 'Push taps are routed by PushService. Local notification taps use the payload configured in NotificationService.',
            child: Text(
              'To handle a push that opens a terminated app, call '
              'PushService.handleLaunchMessage() during app startup. '
              'Register the background message handler before runApp().',
              style: TextStyle(
                color: Color(0xFF657187),
                fontSize: 13,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageTile extends StatelessWidget {
  const _MessageTile({required this.message});

  final RemoteMessage message;

  @override
  Widget build(BuildContext context) {
    final title =
        message.notification?.title ??
        message.data['title']?.toString() ??
        'Untitled notification';
    final body =
        message.notification?.body ??
        message.data['body']?.toString() ??
        'No message body';
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const CircleAvatar(
        backgroundColor: Color(0xFFE9EDF4),
        child: Icon(Icons.notifications_none_rounded, color: Color(0xFF172033)),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
      subtitle: Text(body),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: () {
        final details = <String, dynamic>{
          'messageId': message.messageId,
          'data': message.data,
        };
        showDialog<void>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Notification details'),
            content: SingleChildScrollView(
              child: SelectableText(details.toString()),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.child,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: Color(0xFFE8EDF3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: const Color(0xFF53627A)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Color(0xFF172033),
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
                ),
                if (trailing != null) trailing!,
              ],
            ),
            const SizedBox(height: 7),
            Text(
              subtitle,
              style: const TextStyle(
                color: Color(0xFF8290A5),
                fontSize: 12,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 14),
            child,
          ],
        ),
      ),
    );
  }
}
