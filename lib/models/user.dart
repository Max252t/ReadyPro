import 'package:ready_pro/core/enums.dart';

class User {
  final String id;
  final String fullName;
  final UserRole role;
  final String? company;
  final String? avatarUrl;

  User({
    required this.id,
    required this.fullName,
    required this.role,
    this.company,
    this.avatarUrl,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    final roleStr = json['role'] as String;
    final role = UserRole.fromString(roleStr);

    switch (role) {
      case UserRole.organizer:
        return Organizer.fromJson(json);
      case UserRole.curator:
        return Curator.fromJson(json);
      case UserRole.speaker:
        return Speaker.fromJson(json);
      case UserRole.participant:
        return Participant.fromJson(json);
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'role': role.name,
      'company': company,
      'avatar_url': avatarUrl,
    };
  }
}

class Organizer extends User {
  Organizer({
    required super.id,
    required super.fullName,
    super.company,
    super.avatarUrl,
  }) : super(role: UserRole.organizer);

  factory Organizer.fromJson(Map<String, dynamic> json) {
    return Organizer(
      id: json['id'],
      fullName: json['full_name'],
      company: json['company'],
      avatarUrl: json['avatar_url'],
    );
  }
}

class Curator extends User {
  Curator({
    required super.id,
    required super.fullName,
    super.company,
    super.avatarUrl,
  }) : super(role: UserRole.curator);

  factory Curator.fromJson(Map<String, dynamic> json) {
    return Curator(
      id: json['id'],
      fullName: json['full_name'],
      company: json['company'],
      avatarUrl: json['avatar_url'],
    );
  }
}

class Speaker extends User {
  Speaker({
    required super.id,
    required super.fullName,
    super.company,
    super.avatarUrl,
  }) : super(role: UserRole.speaker);

  factory Speaker.fromJson(Map<String, dynamic> json) {
    return Speaker(
      id: json['id'],
      fullName: json['full_name'],
      company: json['company'],
      avatarUrl: json['avatar_url'],
    );
  }
}

class Participant extends User {
  Participant({
    required super.id,
    required super.fullName,
    super.company,
    super.avatarUrl,
  }) : super(role: UserRole.participant);

  factory Participant.fromJson(Map<String, dynamic> json) {
    return Participant(
      id: json['id'],
      fullName: json['full_name'],
      company: json['company'],
      avatarUrl: json['avatar_url'],
    );
  }
}
