import 'package:ready_pro/core/enums.dart';

class Event {
  final String id;
  final String title;
  final String description;
  final EventStatus status;

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      status: EventStatus.fromString(json['status']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'status': status.name,
    };
  }
}
