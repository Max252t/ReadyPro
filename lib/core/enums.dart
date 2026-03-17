enum UserRole {
  organizer,
  curator,
  speaker,
  participant;

  static UserRole fromString(String role) {
    return UserRole.values.firstWhere(
      (e) => e.name == role,
      orElse: () => UserRole.participant,
    );
  }
}

enum EventStatus {
  preparation,
  active,
  finished;

  static EventStatus fromString(String status) {
    return EventStatus.values.firstWhere(
      (e) => e.name == status,
      orElse: () => EventStatus.preparation,
    );
  }
}

enum TalkStatus {
  draft,
  review,
  approved,
  ready;

  static TalkStatus fromString(String status) {
    return TalkStatus.values.firstWhere(
      (e) => e.name == status,
      orElse: () => TalkStatus.draft,
    );
  }
}

enum NotificationType {
  event_invite,
  task_assigned,
  curator_assigned,
  talk_ready,
  question_asked,
  system;

  static NotificationType fromString(String type) {
    return NotificationType.values.firstWhere(
      (e) => e.name == type,
      orElse: () => NotificationType.system,
    );
  }
}
