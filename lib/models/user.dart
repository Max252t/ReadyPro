import 'package:ready_pro/core/enums.dart';

class Profile {
  final String id;
  final String fullName;
  final String email;
  final String? company;
  final String? avatarUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Profile({
    required this.id,
    required this.fullName,
    required this.email,
    this.company,
    this.avatarUrl,
    this.createdAt,
    this.updatedAt,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'],
      fullName: json['full_name'],
      email: json['email'],
      company: json['company'],
      avatarUrl: json['avatar_url'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'full_name': fullName,
    'email': email,
    'company': company,
    'avatar_url': avatarUrl,
  };
}

abstract class User {
  final Profile profile;
  final UserRole role;

  User({required this.profile, required this.role});

  String get id => profile.id;

  factory User.fromProfileAndRole(Profile profile, UserRole role) {
    switch (role) {
      case UserRole.organizer:
        return Organizer(profile: profile);
      case UserRole.curator:
        return Curator(profile: profile);
      case UserRole.speaker:
        return Speaker(profile: profile);
      case UserRole.participant:
        return Participant(profile: profile);
    }
  }
}

class Organizer extends User {
  Organizer({required super.profile}) : super(role: UserRole.organizer);
}

class Curator extends User {
  Curator({required super.profile}) : super(role: UserRole.curator);
}

class Speaker extends User {
  Speaker({required super.profile}) : super(role: UserRole.speaker);
}

class Participant extends User {
  Participant({required super.profile}) : super(role: UserRole.participant);
}
