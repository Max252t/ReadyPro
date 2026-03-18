import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ready_pro/models/feedback.dart';
import 'package:ready_pro/repositories/feedback_repository.dart';

class SupabaseFeedbackRepository implements FeedbackRepository {
  final SupabaseClient _client;

  SupabaseFeedbackRepository(this._client);

  @override
  Future<List<Feedback>> getFeedbackByTalk(String talkId) async {
    final response = await _client
        .from('feedback')
        .select()
        .eq('talk_id', talkId)
        .order('created_at', ascending: false);
    
    final List<dynamic> data = response as List<dynamic>;
    return data.map((json) => Feedback.fromJson(json)).toList();
  }

  @override
  Future<void> submitFeedback(Feedback feedback) async {
    try {
      await _client.from('feedback').insert({
        'talk_id': feedback.talkId,
        'user_id': feedback.userId,
        'rating': feedback.rating,
        'comment': feedback.comment,
      });
    } catch (e) {
      if (e is PostgrestException && e.code == '23505') {
        throw Exception('Вы уже оставляли отзыв к этому докладу');
      }
      rethrow;
    }
  }

  @override
  Future<void> updateFeedback(Feedback feedback) async {
    await _client.from('feedback').update({
      'rating': feedback.rating,
      'comment': feedback.comment,
    }).eq('id', feedback.id);
  }

  @override
  Future<void> deleteFeedback(String id) async {
    await _client.from('feedback').delete().eq('id', id);
  }
}
