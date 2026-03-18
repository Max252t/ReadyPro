import 'package:ready_pro/models/user.dart';

class Message {
  final String id;
  final String talkId;
  final String userId;
  final String content;
  final String? parentId;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final Profile? user;

  Message({
    required this.id,
    required this.talkId,
    required this.userId,
    required this.content,
    this.parentId,
    required this.createdAt,
    this.updatedAt,
    this.user,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'],
      talkId: json['talk_id'],
      userId: json['user_id'],
      content: json['content'],
      parentId: json['parent_id'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
      user: json['profiles'] != null ? Profile.fromJson(json['profiles']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'talk_id': talkId,
      'user_id': userId,
      'content': content,
      'parent_id': parentId,
    };
  }
}
