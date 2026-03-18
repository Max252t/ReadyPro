import 'package:ready_pro/models/event.dart';
import 'package:ready_pro/core/enums.dart';

class UserEvent {
  final String eventId;
  final String title;
  final String? imageUrl;
  final EventStatus status;
  final UserRole role;
  final DateTime joinedAt;

  UserEvent({
    required this.eventId,
    required this.title,
    this.imageUrl,
    required this.status,
    required this.role,
    required this.joinedAt,
  });

  factory UserEvent.fromJson(Map<String, dynamic> json) {
    return UserEvent(
      eventId: json['event_id'],
      title: json['event_title'],
      imageUrl: json['image_url'],
      status: EventStatus.fromString(json['event_status']),
      role: UserRole.fromString(json['user_role']),
      joinedAt: DateTime.parse(json['joined_at']),
    );
  }
}
