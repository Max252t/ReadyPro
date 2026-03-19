import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ready_pro/repositories/event_repository.dart';
import 'package:ready_pro/repositories/section_repository.dart';
import 'package:ready_pro/repositories/task_repository.dart';
import 'package:ready_pro/repositories/talk_repository.dart';
import 'package:ready_pro/models/talk.dart';
import 'organizer_event.dart';
import 'organizer_state.dart';

class OrganizerBloc extends Bloc<OrganizerEvent, OrganizerState> {
  final EventRepository eventRepository;
  final SectionRepository sectionRepository;
  final TaskRepository taskRepository;
  final TalkRepository talkRepository;

  OrganizerBloc({
    required this.eventRepository,
    required this.sectionRepository,
    required this.taskRepository,
    required this.talkRepository,
  }) : super(OrganizerInitial()) {
    on<FetchOrganizerDashboard>(_onFetchOrganizerDashboard);
    on<CreateSection>(_onCreateSection);
    on<UpdateSection>(_onUpdateSection);
    on<DeleteSection>(_onDeleteSection);
    on<CreateTask>(_onCreateTask);
    on<UpdateTask>(_onUpdateTask);
    on<DeleteTask>(_onDeleteTask);
  }

  Future<void> _onFetchOrganizerDashboard(
    FetchOrganizerDashboard event,
    Emitter<OrganizerState> emit,
  ) async {
    emit(OrganizerLoading());
    try {
      final eventDetails = await eventRepository.getEventById(event.eventId);
      final sections = await sectionRepository.getSectionsByEvent(event.eventId);
      final tasks = await taskRepository.getTasksByEvent(event.eventId);
      
      List<Talk> allTalks = [];
      for (final section in sections) {
        final talks = await talkRepository.getTalksBySection(section.id);
        allTalks.addAll(talks);
      }

      emit(OrganizerDashboardLoaded(
        event: eventDetails,
        sections: sections,
        tasks: tasks,
        talks: allTalks,
      ));
    } catch (e) {
      emit(OrganizerError(e.toString()));
    }
  }

  Future<void> _onCreateSection(CreateSection event, Emitter<OrganizerState> emit) async {
    try {
      await sectionRepository.createSection(event.section);
      add(FetchOrganizerDashboard(event.section.eventId));
    } catch (e) {
      emit(OrganizerError(e.toString()));
    }
  }

  Future<void> _onUpdateSection(UpdateSection event, Emitter<OrganizerState> emit) async {
    try {
      await sectionRepository.updateSection(event.section);
      add(FetchOrganizerDashboard(event.section.eventId));
    } catch (e) {
      emit(OrganizerError(e.toString()));
    }
  }

  Future<void> _onDeleteSection(DeleteSection event, Emitter<OrganizerState> emit) async {
    try {
      await sectionRepository.deleteSection(event.sectionId);
      add(FetchOrganizerDashboard(event.eventId));
    } catch (e) {
      emit(OrganizerError(e.toString()));
    }
  }

  Future<void> _onCreateTask(CreateTask event, Emitter<OrganizerState> emit) async {
    try {
      await taskRepository.createTask(event.task);
      add(FetchOrganizerDashboard(event.task.eventId));
    } catch (e) {
      emit(OrganizerError(e.toString()));
    }
  }

  Future<void> _onUpdateTask(UpdateTask event, Emitter<OrganizerState> emit) async {
    try {
      await taskRepository.updateTask(event.task);
      add(FetchOrganizerDashboard(event.task.eventId));
    } catch (e) {
      emit(OrganizerError(e.toString()));
    }
  }

  Future<void> _onDeleteTask(DeleteTask event, Emitter<OrganizerState> emit) async {
    try {
      await taskRepository.deleteTask(event.taskId);
      add(FetchOrganizerDashboard(event.eventId));
    } catch (e) {
      emit(OrganizerError(e.toString()));
    }
  }
}
