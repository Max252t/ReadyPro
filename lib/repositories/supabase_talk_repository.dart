import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ready_pro/models/talk.dart';
import 'package:ready_pro/repositories/talk_repository.dart';
import 'package:ready_pro/core/enums.dart';

class SupabaseTalkRepository implements TalkRepository {
  final SupabaseClient _client;

  SupabaseTalkRepository(this._client);

  @override
  Future<List<Talk>> getTalksBySection(String sectionId) async {
    final response = await _client
        .from('talks')
        .select()
        .eq('section_id', sectionId)
        .order('start_time', ascending: true);
    
    final List<dynamic> data = response as List<dynamic>;
    return data.map((json) => Talk.fromJson(json)).toList();
  }

  @override
  Future<Talk> getTalkById(String id) async {
    final data = await _client
        .from('talks')
        .select()
        .eq('id', id)
        .single();
    return Talk.fromJson(data);
  }

  @override
  Future<void> createTalk(Talk talk) async {
    await _client.from('talks').insert({
      'section_id': talk.sectionId,
      'speaker_id': talk.speakerId,
      'title': talk.title,
      'description': talk.description,
      'status': talk.status.name,
      'start_time': talk.startTime?.toIso8601String(),
      'end_time': talk.endTime?.toIso8601String(),
      'room': talk.room,
      'materials_url': talk.materialsUrl,
    });
  }

  @override
  Future<void> updateTalk(Talk talk) async {
    await _client.from('talks').update({
      'title': talk.title,
      'description': talk.description,
      'status': talk.status.name,
      'start_time': talk.startTime?.toIso8601String(),
      'end_time': talk.endTime?.toIso8601String(),
      'room': talk.room,
      'materials_url': talk.materialsUrl,
    }).eq('id', talk.id);
  }

  @override
  Future<void> deleteTalk(String id) async {
    await _client.from('talks').delete().eq('id', id);
  }
}
