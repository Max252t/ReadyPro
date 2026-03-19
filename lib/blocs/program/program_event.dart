import 'package:equatable/equatable.dart';
import 'package:ready_pro/models/talk.dart';

abstract class ProgramEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchProgram extends ProgramEvent {
  final String eventId;
  final String userId;
  FetchProgram({required this.eventId, required this.userId});
  @override
  List<Object?> get props => [eventId, userId];
}

class FetchSpeakerTalks extends ProgramEvent {
  final String speakerId;
  final String eventId;
  FetchSpeakerTalks({required this.speakerId, required this.eventId});
  @override
  List<Object?> get props => [speakerId, eventId];
}

class ToggleScheduleRequested extends ProgramEvent {
  final String talkId;
  final String userId;
  ToggleScheduleRequested({required this.talkId, required this.userId});
  @override
  List<Object?> get props => [talkId, userId];
}

class CreateTalk extends ProgramEvent {
  final Talk talk;
  final String eventId;
  final String userId;
  CreateTalk({required this.talk, required this.eventId, required this.userId});
  @override
  List<Object?> get props => [talk, eventId, userId];
}

class UpdateTalk extends ProgramEvent {
  final Talk talk;
  final String eventId;
  final String userId;
  UpdateTalk({required this.talk, required this.eventId, required this.userId});
  @override
  List<Object?> get props => [talk, eventId, userId];
}

class DeleteTalk extends ProgramEvent {
  final String talkId;
  final String eventId;
  final String userId;
  DeleteTalk({required this.talkId, required this.eventId, required this.userId});
  @override
  List<Object?> get props => [talkId, eventId, userId];
}
