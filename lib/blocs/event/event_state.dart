import 'package:equatable/equatable.dart';
import 'package:ready_pro/models/user_event.dart';
import 'package:ready_pro/models/event.dart';
import 'package:ready_pro/models/user.dart';

abstract class EventState extends Equatable {
  @override
  List<Object?> get props => [];
}

class EventInitial extends EventState {}

class EventLoading extends EventState {}

class EventsLoaded extends EventState {
  final List<UserEvent> events;
  EventsLoaded(this.events);
  @override
  List<Object?> get props => [events];
}

class AllEventsLoaded extends EventState {
  final List<Event> events;
  AllEventsLoaded(this.events);
  @override
  List<Object?> get props => [events];
}

class SingleEventLoaded extends EventState {
  final Event event;
  SingleEventLoaded(this.event);
  @override
  List<Object?> get props => [event];
}

class EventParticipantsLoaded extends EventState {
  final List<Profile> participants;
  EventParticipantsLoaded(this.participants);
  @override
  List<Object?> get props => [participants];
}

class EventOperationSuccess extends EventState {
  final String message;
  EventOperationSuccess(this.message);
  @override
  List<Object?> get props => [message];
}

class EventFailure extends EventState {
  final String message;
  EventFailure(this.message);
  @override
  List<Object?> get props => [message];
}
