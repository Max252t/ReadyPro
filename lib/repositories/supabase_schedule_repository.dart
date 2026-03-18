import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ready_pro/models/talk.dart';
import 'package:ready_pro/repositories/schedule_repository.dart';

class SupabaseScheduleRepository implements ScheduleRepository {
  final SupabaseClient _client;

  SupabaseScheduleRepository(this._client);

  @override
  Future<List<Talk>> getUserSchedule(String userId) async {
    final response = await _client
        .from('schedule')
        .select('talks (*)')
        .eq('user_id', userId);
    
    final List<dynamic> data = response as List<dynamic>;
    return data.map((json) => Talk.fromJson(json['talks'])).toList();
  }

  @override
  Future<void> addToSchedule(String userId, String talkId) async {
    await _client.from('schedule').insert({
      'user_id': userId,
      'talk_id': talkId,
    });
  }

  @override
  Future<void> removeFromSchedule(String userId, String talkId) async {
    await _client
        .from('schedule')
        .delete()
        .eq('user_id', userId)
        .eq('talk_id', talkId);
  }

  @override
  Future<bool> isInSchedule(String userId, String talkId) async {
    final response = await _client
        .from('schedule')
        .select()
        .eq('user_id', userId)
        .eq('talk_id', talkId)
        .maybeSingle();
    return response != null;
  }
}
