import 'package:ready_pro/models/event.dart';
import 'package:ready_pro/models/user_event.dart';
import 'package:ready_pro/models/user.dart';
import 'package:ready_pro/core/enums.dart';

abstract class EventRepository {
  Future<List<Event>> getEvents();
  Future<List<UserEvent>> getUserEvents(String userId);
  Future<Event> getEventById(String id);
  Future<void> createEvent(Event event);
  Future<void> updateEvent(Event event);
  Future<void> deleteEvent(String id);
  
  Future<void> assignRole({
    required String eventId,
    required String email,
    required UserRole role,
  });

  Future<List<Profile>> getEventParticipants(String eventId, {UserRole? role});
}
