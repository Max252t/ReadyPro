class Schedule {
  final String userId;
  final String talkId;

  Schedule({
    required this.userId,
    required this.talkId,
  });

  factory Schedule.fromJson(Map<String, dynamic> json) {
    return Schedule(
      userId: json['user_id'],
      talkId: json['talk_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'talk_id': talkId,
    };
  }
}
