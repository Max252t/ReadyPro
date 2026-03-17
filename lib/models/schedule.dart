class Schedule {
  final String id;
  final String userId;
  final String talkId;
  final DateTime? createdAt;

  Schedule({
    required this.id,
    required this.userId,
    required this.talkId,
    this.createdAt,
  });

  factory Schedule.fromJson(Map<String, dynamic> json) {
    return Schedule(
      id: json['id'],
      userId: json['user_id'],
      talkId: json['talk_id'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'talk_id': talkId,
    };
  }
}
