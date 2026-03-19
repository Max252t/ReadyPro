import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ready_pro/models/event.dart';
import 'package:ready_pro/models/user_event.dart';
import 'package:ready_pro/models/user.dart';
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
      final userData = await _client
          .from('profiles')
          .select('id')
          .eq('email', email)
          .single();
      
      final userId = userData['id'];

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
  Future<void> joinEvent({
    required String eventId,
    required String userId,
    required UserRole role,
  }) async {
    try {
      await _client.from('event_participants').upsert({
        'event_id': eventId,
        'user_id': userId,
        'role': role.name,
        'joined_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<Profile>> getEventParticipants(String eventId, {UserRole? role}) async {
    var query = _client.from('event_participants').select('profiles(*)').eq('event_id', eventId);
    
    if (role != null) {
      query = query.eq('role', role.name);
    }
    
    final response = await query;
    final List<dynamic> data = response as List<dynamic>;
    return data.map((item) => Profile.fromJson(item['profiles'])).toList();
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
  Future<String?> uploadEventImage(String eventId, dynamic imageFile) async {
    try {
      final fileName = 'events/$eventId/cover_${DateTime.now().millisecondsSinceEpoch}.png';
      
      if (kIsWeb) {
        final bytes = await (imageFile as dynamic).readAsBytes();
        await _client.storage.from('event_images').uploadBinary(
          fileName,
          bytes,
          fileOptions: const FileOptions(upsert: true, contentType: 'image/png'),
        );
      } else {
        await _client.storage.from('event_images').upload(
          fileName,
          imageFile,
          fileOptions: const FileOptions(upsert: true, contentType: 'image/png'),
        );
      }
      
      return _client.storage.from('event_images').getPublicUrl(fileName);
    } catch (e) {
      print('Error uploading event image: $e');
      return null;
    }
  }

  @override
  Future<String> createEvent(Event event) async {
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
        'image_url': event.imageUrl,
      };

      final inserted = await _client
          .from('events')
          .insert(eventData)
          .select('id')
          .single();

      final id = inserted['id'];
      if (id is String) return id;
      return id.toString();
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
      'image_url': event.imageUrl,
      'status': event.status.name,
    }).eq('id', event.id);
  }

  @override
  Future<void> deleteEvent(String id) async {
    await _client.from('events').delete().eq('id', id);
  }
}
