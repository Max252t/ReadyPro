class Feedback {
  final String id;
  final String talkId;
  final String userId;
  final int rating;
  final String comment;

  Feedback({
    required this.id,
    required this.talkId,
    required this.userId,
    required this.rating,
    required this.comment,
  });

  factory Feedback.fromJson(Map<String, dynamic> json) {
    return Feedback(
      id: json['id'],
      talkId: json['talk_id'],
      userId: json['user_id'],
      rating: json['rating'],
      comment: json['comment'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'talk_id': talkId,
      'user_id': userId,
      'rating': rating,
      'comment': comment,
    };
  }
}
