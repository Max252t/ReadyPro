class UiUser {
  final String id;
  final String email;
  final String name;
  final UiRole role;

  const UiUser({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
  });
}

enum UiRole { organizer, curator, speaker, participant }

class UiEvent {
  final String id;
  final String name;
  final String description;
  final DateTime startDate;
  final DateTime endDate;

  const UiEvent({
    required this.id,
    required this.name,
    required this.description,
    required this.startDate,
    required this.endDate,
  });
}

class UiSection {
  final String id;
  final String eventId;
  final String name;
  final String description;
  final String? curatorId;
  final String? room;

  const UiSection({
    required this.id,
    required this.eventId,
    required this.name,
    required this.description,
    this.curatorId,
    this.room,
  });
}

enum UiTalkStatus { ready, draft }

class UiTalk {
  final String id;
  final String sectionId;
  final String speakerId;
  final String title;
  final String description;
  final DateTime startTime;
  final int durationMin;
  final String? room;
  final UiTalkStatus status;

  const UiTalk({
    required this.id,
    required this.sectionId,
    required this.speakerId,
    required this.title,
    required this.description,
    required this.startTime,
    required this.durationMin,
    this.room,
    required this.status,
  });
}

class UiTask {
  final String id;
  final String eventId;
  final String assignedTo;
  final String createdBy;
  final String title;
  final String description;
  final bool completed;
  final DateTime dueDate;

  const UiTask({
    required this.id,
    required this.eventId,
    required this.assignedTo,
    required this.createdBy,
    required this.title,
    required this.description,
    required this.completed,
    required this.dueDate,
  });
}

class UiScheduleEntry {
  final String id;
  final String userId;
  final String talkId;
  final DateTime createdAt;

  const UiScheduleEntry({
    required this.id,
    required this.userId,
    required this.talkId,
    required this.createdAt,
  });
}

class UiFeedback {
  final String id;
  final String talkId;
  final String userId;
  final int rating;
  final String? comment;
  final DateTime createdAt;

  const UiFeedback({
    required this.id,
    required this.talkId,
    required this.userId,
    required this.rating,
    this.comment,
    required this.createdAt,
  });
}

class UiComment {
  final String id;
  final String talkId;
  final String userId;
  final String message;
  final DateTime createdAt;
  final String? replyTo;

  const UiComment({
    required this.id,
    required this.talkId,
    required this.userId,
    required this.message,
    required this.createdAt,
    this.replyTo,
  });
}

class UiCuratorReport {
  final String id;
  final String sectionId;
  final String curatorId;
  final String reportText;
  final DateTime createdAt;

  const UiCuratorReport({
    required this.id,
    required this.sectionId,
    required this.curatorId,
    required this.reportText,
    required this.createdAt,
  });
}

