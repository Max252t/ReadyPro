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

  static const int _signedUrlTtlSeconds = 60 * 60; // 1 hour

  String? _extractPublicStoragePath({
    required String publicUrl,
    required String bucket,
  }) {
    // Example:
    // https://<project>.supabase.co/storage/v1/object/public/<bucket>/<path>
    final marker = '/storage/v1/object/public/$bucket/';
    final idx = publicUrl.indexOf(marker);
    if (idx == -1) return null;
    return publicUrl.substring(idx + marker.length);
  }

  Future<String?> _maybeCreateSignedImageUrl({
    required String? imageUrl,
    required String bucket,
  }) async {
    if (imageUrl == null || imageUrl.isEmpty) return null;

    // If it's already not a public storage URL, keep it as-is.
    if (!imageUrl.contains('/storage/v1/object/public/$bucket/')) return imageUrl;

    final path = _extractPublicStoragePath(
      publicUrl: imageUrl,
      bucket: bucket,
    );
    if (path == null || path.isEmpty) return imageUrl;

    try {
      return await _client.storage.from(bucket).createSignedUrl(
            path,
            _signedUrlTtlSeconds,
          );
    } catch (e) {
      print('CreateSignedUrl (storage=$bucket) failed: $e');
      return imageUrl;
    }
  }

  @override
  Future<List<Event>> getEvents() async {
    try {
      final List<dynamic> response = await _client
          .from('events')
          .select()
          .order('start_date', ascending: true);

      final events = response.map((json) => Event.fromJson(json)).toList();
      final signedEvents = await Future.wait(events.map((event) async {
        if (event.imageUrl == null || event.imageUrl!.isEmpty) return event;
        final signedUrl = await _maybeCreateSignedImageUrl(
          imageUrl: event.imageUrl,
          bucket: 'event_images',
        );
        if (signedUrl == null || signedUrl.isEmpty) return event;
        return event.copyWith(imageUrl: signedUrl);
      }));

      return signedEvents;
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
      final userEvents = data.map((json) => UserEvent.fromJson(json)).toList();

      final signedUserEvents = await Future.wait(userEvents.map((ue) async {
        final signedUrl = await _maybeCreateSignedImageUrl(
          imageUrl: ue.imageUrl,
          bucket: 'event_images',
        );
        if (signedUrl == null || signedUrl.isEmpty) return ue;

        return UserEvent(
          eventId: ue.eventId,
          title: ue.title,
          imageUrl: signedUrl,
          status: ue.status,
          role: ue.role,
          joinedAt: ue.joinedAt,
        );
      }));

      return signedUserEvents;
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
    final event = Event.fromJson(data);
    final signedUrl = await _maybeCreateSignedImageUrl(
      imageUrl: event.imageUrl,
      bucket: 'event_images',
    );
    if (signedUrl == null || signedUrl.isEmpty) return event;
    return event.copyWith(imageUrl: signedUrl);
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
