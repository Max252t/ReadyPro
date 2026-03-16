class Task {
  final String id;
  final String eventId;
  final String assigneeId;
  final String assignerId;
  final String title;
  final String description;
  final DateTime dueDate;
  final bool isCompleted;

  Task({
    required this.id,
    required this.eventId,
    required this.assigneeId,
    required this.assignerId,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.isCompleted,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      eventId: json['event_id'],
      assigneeId: json['assignee_id'],
      assignerId: json['assigner_id'],
      title: json['title'],
      description: json['description'],
      dueDate: DateTime.parse(json['due_date']),
      isCompleted: json['status'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'event_id': eventId,
      'assignee_id': assigneeId,
      'assigner_id': assignerId,
      'title': title,
      'description': description,
      'due_date': dueDate.toIso8601String(),
      'status': isCompleted,
    };
  }
}
