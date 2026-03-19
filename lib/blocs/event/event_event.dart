import 'package:equatable/equatable.dart';
import 'package:ready_pro/models/event.dart';
import 'package:ready_pro/core/enums.dart';

abstract class EventEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadMyEvents extends EventEvent {
  final String userId;
  LoadMyEvents(this.userId);
  @override
  List<Object?> get props => [userId];
}

class LoadAllEvents extends EventEvent {}

class LoadEventParticipants extends EventEvent {
  final String eventId;
  final UserRole? role;
  LoadEventParticipants(this.eventId, {this.role});
  @override
  List<Object?> get props => [eventId, role];
}

class CreateEventRequested extends EventEvent {
  final Event event;
  final dynamic imageFile;
  CreateEventRequested(this.event, {this.imageFile});
  @override
  List<Object?> get props => [event, imageFile];
}

class JoinEventRequested extends EventEvent {
  final String eventId;
  final String userId;
  final UserRole role;
  JoinEventRequested({required this.eventId, required this.userId, this.role = UserRole.participant});
  @override
  List<Object?> get props => [eventId, userId, role];
}

class DeleteEventRequested extends EventEvent {
  final String eventId;
  DeleteEventRequested(this.eventId);
  @override
  List<Object?> get props => [eventId];
}

class AssignRoleRequested extends EventEvent {
  final String eventId;
  final String email;
  final UserRole role;
  AssignRoleRequested({required this.eventId, required this.email, required this.role});
  @override
  List<Object?> get props => [eventId, email, role];
}
