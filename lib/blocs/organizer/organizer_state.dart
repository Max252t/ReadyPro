import 'package:equatable/equatable.dart';
import 'package:ready_pro/models/event.dart';
import 'package:ready_pro/models/section.dart';
import 'package:ready_pro/models/task.dart';
import 'package:ready_pro/models/talk.dart';

abstract class OrganizerState extends Equatable {
  const OrganizerState();

  @override
  List<Object?> get props => [];
}

class OrganizerInitial extends OrganizerState {}

class OrganizerLoading extends OrganizerState {}

class OrganizerDashboardLoaded extends OrganizerState {
  final Event event;
  final List<Section> sections;
  final List<Task> tasks;
  final List<Talk> talks;

  const OrganizerDashboardLoaded({
    required this.event,
    required this.sections,
    required this.tasks,
    required this.talks,
  });

  @override
  List<Object?> get props => [event, sections, tasks, talks];
}

class OrganizerError extends OrganizerState {
  final String message;

  const OrganizerError(this.message);

  @override
  List<Object?> get props => [message];
}
