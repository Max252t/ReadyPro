import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ready_pro/repositories/event_repository.dart';
import 'package:ready_pro/core/enums.dart';
import 'event_event.dart';
import 'event_state.dart';

class EventBloc extends Bloc<EventEvent, EventState> {
  final EventRepository _eventRepository;

  EventBloc(this._eventRepository) : super(EventInitial()) {
    on<LoadMyEvents>(_onLoadMyEvents);
    on<LoadAllEvents>(_onLoadAllEvents);
    on<LoadEventById>(_onLoadEventById);
    on<CreateEventRequested>(_onCreateEventRequested);
    on<JoinEventRequested>(_onJoinEventRequested);
    on<DeleteEventRequested>(_onDeleteEventRequested);
    on<AssignRoleRequested>(_onAssignRoleRequested);
    on<LoadEventParticipants>(_onLoadEventParticipants);
  }

  Future<void> _onLoadMyEvents(
    LoadMyEvents event,
    Emitter<EventState> emit,
  ) async {
    emit(EventLoading());
    try {
      final events = await _eventRepository.getUserEvents(event.userId);
      emit(EventsLoaded(events));
    } catch (e) {
      emit(EventFailure(e.toString()));
    }
  }

  Future<void> _onLoadAllEvents(
    LoadAllEvents event,
    Emitter<EventState> emit,
  ) async {
    emit(EventLoading());
    try {
      final events = await _eventRepository.getEvents();
      emit(AllEventsLoaded(events));
    } catch (e) {
      emit(EventFailure(e.toString()));
    }
  }

  Future<void> _onLoadEventById(
    LoadEventById event,
    Emitter<EventState> emit,
  ) async {
    // Note: If we want to return the event via state, we need a SingleEventLoaded state.
    // For now, if the UI needs it, we can add it or return it from a method if UI calls repository.
    // However, following the BLoC pattern strictly:
    emit(EventLoading());
    try {
      final eventData = await _eventRepository.getEventById(event.eventId);
      emit(SingleEventLoaded(eventData));
    } catch (e) {
      emit(EventFailure(e.toString()));
    }
  }

  // Adding a helper for direct access if needed, though BLoC usually uses states
  Future<dynamic> getEventById(String id) => _eventRepository.getEventById(id);

  Future<void> _onLoadEventParticipants(
    LoadEventParticipants event,
    Emitter<EventState> emit,
  ) async {
    emit(EventLoading());
    try {
      final participants = await _eventRepository.getEventParticipants(event.eventId, role: event.role);
      emit(EventParticipantsLoaded(participants));
    } catch (e) {
      emit(EventFailure(e.toString()));
    }
  }

  Future<void> _onJoinEventRequested(
    JoinEventRequested event,
    Emitter<EventState> emit,
  ) async {
    emit(EventLoading());
    try {
      await _eventRepository.joinEvent(
        eventId: event.eventId,
        userId: event.userId,
        role: event.role,
      );
      emit(EventOperationSuccess('Вы успешно присоединились к мероприятию'));
      add(LoadMyEvents(event.userId));
    } catch (e) {
      emit(EventFailure(e.toString()));
    }
  }

  Future<void> _onCreateEventRequested(
    CreateEventRequested event,
    Emitter<EventState> emit,
  ) async {
    emit(EventLoading());
    try {
      String? imageUrl;
      if (event.imageFile != null) {
        // Use a UUID or timestamp for temp image ID if needed
        final tempId = DateTime.now().millisecondsSinceEpoch.toString();
        imageUrl = await _eventRepository.uploadEventImage(tempId, event.imageFile);
      }
      
      final eventToCreate = event.event.copyWith(imageUrl: imageUrl);
      await _eventRepository.createEvent(eventToCreate);
      
      emit(EventOperationSuccess('Мероприятие создано'));
      // Refresh my events after creation
      add(LoadMyEvents(event.event.createdBy));
    } catch (e) {
      emit(EventFailure(e.toString()));
    }
  }

  Future<void> _onDeleteEventRequested(
    DeleteEventRequested event,
    Emitter<EventState> emit,
  ) async {
    try {
      await _eventRepository.deleteEvent(event.eventId);
      emit(EventOperationSuccess('Мероприятие удалено'));
    } catch (e) {
      emit(EventFailure(e.toString()));
    }
  }

  Future<void> _onAssignRoleRequested(
    AssignRoleRequested event,
    Emitter<EventState> emit,
  ) async {
    try {
      await _eventRepository.assignRole(
        eventId: event.eventId,
        email: event.email,
        role: event.role,
      );
      emit(EventOperationSuccess('Роль назначена'));
    } catch (e) {
      emit(EventFailure(e.toString()));
    }
  }
}
