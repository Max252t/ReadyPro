import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ready_pro/models/event.dart';
import 'package:ready_pro/models/user_event.dart';
import 'package:ready_pro/repositories/event_repository.dart';
import 'package:ready_pro/core/enums.dart';

class SupabaseEventRepository implements EventRepository {
  final SupabaseClient _client;

  SupabaseEventRepository(this._client);

  @override
  Future<List<Event>> getEvents() async {
    try {
      final List<dynamic> response = await _client
          .from('events')
          .select()
          .order('start_date', ascending: true);
      
      return response.map((json) => Event.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<UserEvent>> getUserEvents(String userId) async {
    try {
      final response = await _client.rpc(
        'get_user_events',
        params: {'user_uuid': userId},
      );
      
      final List<dynamic> data = response as List<dynamic>;
      return data.map((json) => UserEvent.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> assignRole({
    required String eventId,
    required String email,
    required UserRole role,
  }) async {
    try {
      // 1. Находим пользователя по email
      final userData = await _client
          .from('profiles')
          .select('id')
          .eq('email', email)
          .single();
      
      final userId = userData['id'];

      // 2. Добавляем его в event_participants
      await _client.from('event_participants').upsert({
        'event_id': eventId,
        'user_id': userId,
        'role': role.name,
        'joined_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      if (e is PostgrestException && e.code == 'PGRST116') {
        throw Exception('Пользователь с таким email не найден');
      }
      rethrow;
    }
  }

  @override
  Future<Event> getEventById(String id) async {
    final data = await _client
        .from('events')
        .select()
        .eq('id', id)
        .single();
    return Event.fromJson(data);
  }

  @override
  Future<void> createEvent(Event event) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) throw Exception('Пользователь не авторизован');

      final eventData = {
        'title': event.title,
        'description': event.description,
        'start_date': event.startDate?.toIso8601String(),
        'end_date': event.endDate?.toIso8601String(),
        'location': event.location,
        'status': event.status.name,
        'created_by': user.id,
      };

      await _client.from('events').insert(eventData);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> updateEvent(Event event) async {
    await _client.from('events').update({
      'title': event.title,
      'description': event.description,
      'start_date': event.startDate?.toIso8601String(),
      'end_date': event.endDate?.toIso8601String(),
      'location': event.location,
      'status': event.status.name,
    }).eq('id', event.id);
  }

  @override
  Future<void> deleteEvent(String id) async {
    await _client.from('events').delete().eq('id', id);
  }
}
