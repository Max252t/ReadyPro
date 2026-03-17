import 'package:ready_pro/models/event.dart';
import 'package:ready_pro/models/user_event.dart';

abstract class EventRepository {
  Future<List<Event>> getEvents();
  Future<List<UserEvent>> getUserEvents(String userId); // Новый метод
  Future<Event> getEventById(String id);
  Future<void> createEvent(Event event);
  Future<void> updateEvent(Event event);
  Future<void> deleteEvent(String id);
}
