import 'package:ready_pro/core/enums.dart';

class Talk {
  final String id;
  final String sectionId;
  final String speakerId;
  final String title;
  final String? description;
  final TalkStatus status;
  final DateTime? startTime;
  final DateTime? endTime;
  final String? room;
  final List<String> materialsUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Talk({
    required this.id,
    required this.sectionId,
    required this.speakerId,
    required this.title,
    this.description,
    required this.status,
    this.startTime,
    this.endTime,
    this.room,
    this.materialsUrl = const [],
    this.createdAt,
    this.updatedAt,
  });

  factory Talk.fromJson(Map<String, dynamic> json) {
    return Talk(
      id: json['id'],
      sectionId: json['section_id'],
      speakerId: json['speaker_id'],
      title: json['title'],
      description: json['description'],
      status: TalkStatus.fromString(json['status']),
      startTime: json['start_time'] != null ? DateTime.parse(json['start_time']) : null,
      endTime: json['end_time'] != null ? DateTime.parse(json['end_time']) : null,
      room: json['room'],
      materialsUrl: json['materials_url'] != null ? List<String>.from(json['materials_url']) : [],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'section_id': sectionId,
      'speaker_id': speakerId,
      'title': title,
      'description': description,
      'status': status.name,
      'start_time': startTime?.toIso8601String(),
      'end_time': endTime?.toIso8601String(),
      'room': room,
      'materials_url': materialsUrl,
    };
  }
}
