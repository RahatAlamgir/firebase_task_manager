import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class NotificationDetailPage extends StatelessWidget {
  const NotificationDetailPage({
    super.key,
    required this.title,
    required this.body,
    this.receivedAt,
    this.messageId,
    this.data = const <String, dynamic>{},
    this.source = NotificationSource.push,
    this.isRead = false,
    this.onMarkRead,
  });

  final String title;
  final String body;
  final DateTime? receivedAt;
  final String? messageId;
  final Map<String, dynamic> data;
  final NotificationSource source;
  final bool isRead;
  final VoidCallback? onMarkRead;

  factory NotificationDetailPage.fromRemoteMessage(
    RemoteMessage message, {
    Key? key,
    VoidCallback? onMarkRead,
  }) {
    return NotificationDetailPage(
      key: key,
      title:
          message.notification?.title ??
          message.data['title']?.toString() ??
          'Notification',
      body:
          message.notification?.body ??
          message.data['body']?.toString() ??
          'No message body',
      receivedAt: message.sentTime,
      messageId: message.messageId,
      data: message.data,
      source: NotificationSource.push,
      onMarkRead: onMarkRead,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final dateText = receivedAt == null
        ? 'Time not available'
        : '${MaterialLocalizations.of(context).formatFullDate(receivedAt!)} • '
              '${TimeOfDay.fromDateTime(receivedAt!).format(context)}';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Notification details'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF172033),
        elevation: 0,
        actions: [
          if (!isRead && onMarkRead != null)
            TextButton(onPressed: onMarkRead, child: const Text('Mark read')),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: const Color(0xFFE8EDF3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: colors.primaryContainer,
                    borderRadius: BorderRadius.circular(17),
                  ),
                  child: Icon(
                    source == NotificationSource.push
                        ? Icons.cloud_done_outlined
                        : Icons.notifications_active_outlined,
                    color: colors.onPrimaryContainer,
                    size: 27,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    _Tag(
                      label: source.label,
                      color: colors.primaryContainer,
                      foreground: colors.onPrimaryContainer,
                    ),
                    const SizedBox(width: 8),
                    _Tag(
                      label: isRead ? 'Read' : 'Unread',
                      color: isRead
                          ? const Color(0xFFE7F8F1)
                          : const Color(0xFFFFF1D9),
                      foreground: isRead
                          ? const Color(0xFF258566)
                          : const Color(0xFF99610B),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: const Color(0xFF172033),
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  body,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: const Color(0xFF53627A),
                    height: 1.55,
                  ),
                ),
                const SizedBox(height: 20),
                const Divider(color: Color(0xFFE8EDF3)),
                const SizedBox(height: 12),
                _MetadataRow(
                  icon: Icons.schedule_rounded,
                  label: 'Received',
                  value: dateText,
                ),
                if (messageId != null && messageId!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _MetadataRow(
                    icon: Icons.tag_rounded,
                    label: 'Message ID',
                    value: messageId!,
                  ),
                ],
              ],
            ),
          ),
          if (data.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: const Color(0xFFE8EDF3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Additional data',
                    style: TextStyle(
                      color: Color(0xFF172033),
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Custom values sent with this notification.',
                    style: TextStyle(color: Color(0xFF8290A5), fontSize: 12),
                  ),
                  const SizedBox(height: 12),
                  ...data.entries.map(
                    (entry) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 100,
                            child: Text(
                              entry.key,
                              style: const TextStyle(
                                color: Color(0xFF657187),
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: SelectableText(
                              entry.value?.toString() ?? 'null',
                              style: const TextStyle(
                                color: Color(0xFF172033),
                                fontSize: 12,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

enum NotificationSource {
  push,
  local;

  String get label => switch (this) {
    NotificationSource.push => 'FCM push',
    NotificationSource.local => 'Local',
  };
}

class _Tag extends StatelessWidget {
  const _Tag({
    required this.label,
    required this.color,
    required this.foreground,
  });

  final String label;
  final Color color;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: foreground,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _MetadataRow extends StatelessWidget {
  const _MetadataRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 17, color: const Color(0xFF8290A5)),
        const SizedBox(width: 9),
        SizedBox(
          width: 78,
          child: Text(
            label,
            style: const TextStyle(color: Color(0xFF8290A5), fontSize: 12),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: SelectableText(
            value,
            style: const TextStyle(
              color: Color(0xFF53627A),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
