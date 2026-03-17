import 'package:ready_pro/core/enums.dart';

class AppNotification {
  final String id;
  final String userId;
  final String? eventId;
  final String title;
  final String? content;
  final NotificationType type;
  final bool isRead;
  final Map<String, dynamic>? data;
  final DateTime createdAt;

  AppNotification({
    required this.id,
    required this.userId,
    this.eventId,
    required this.title,
    this.content,
    required this.type,
    required this.isRead,
    this.data,
    required this.createdAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'],
      userId: json['user_id'],
      eventId: json['event_id'],
      title: json['title'],
      content: json['content'],
      type: NotificationType.fromString(json['type']),
      isRead: json['is_read'] ?? false,
      data: json['data'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'event_id': eventId,
      'title': title,
      'content': content,
      'type': type.name,
      'is_read': isRead,
      'data': data,
    };
  }
}
