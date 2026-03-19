import 'package:equatable/equatable.dart';
import 'package:ready_pro/models/section.dart';
import 'package:ready_pro/models/task.dart';

abstract class OrganizerEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchOrganizerDashboard extends OrganizerEvent {
  final String eventId;
  FetchOrganizerDashboard(this.eventId);
  @override
  List<Object?> get props => [eventId];
}

class FetchSections extends OrganizerEvent {
  final String eventId;
  FetchSections(this.eventId);
  @override
  List<Object?> get props => [eventId];
}

class CreateSection extends OrganizerEvent {
  final Section section;
  CreateSection(this.section);
  @override
  List<Object?> get props => [section];
}

class UpdateSection extends OrganizerEvent {
  final Section section;
  UpdateSection(this.section);
  @override
  List<Object?> get props => [section];
}

class DeleteSection extends OrganizerEvent {
  final String sectionId;
  final String eventId;
  DeleteSection(this.sectionId, this.eventId);
  @override
  List<Object?> get props => [sectionId, eventId];
}

class FetchTasks extends OrganizerEvent {
  final String eventId;
  FetchTasks(this.eventId);
  @override
  List<Object?> get props => [eventId];
}

class CreateTask extends OrganizerEvent {
  final Task task;
  CreateTask(this.task);
  @override
  List<Object?> get props => [task];
}

class UpdateTask extends OrganizerEvent {
  final Task task;
  UpdateTask(this.task);
  @override
  List<Object?> get props => [task];
}

class DeleteTask extends OrganizerEvent {
  final String taskId;
  final String eventId;
  DeleteTask(this.taskId, this.eventId);
  @override
  List<Object?> get props => [taskId, eventId];
}
