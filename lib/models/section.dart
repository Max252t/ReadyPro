class Section {
  final String id;
  final String eventId;
  final String name;
  final String curatorId;
  final int progress;

  Section({
    required this.id,
    required this.eventId,
    required this.name,
    required this.curatorId,
    required this.progress,
  });

  factory Section.fromJson(Map<String, dynamic> json) {
    return Section(
      id: json['id'],
      eventId: json['event_id'],
      name: json['name'],
      curatorId: json['curator_id'],
      progress: json['progress'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'event_id': eventId,
      'name': name,
      'curator_id': curatorId,
      'progress': progress,
    };
  }
}
