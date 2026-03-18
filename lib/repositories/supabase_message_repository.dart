import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ready_pro/models/message.dart';
import 'package:ready_pro/repositories/message_repository.dart';

class SupabaseMessageRepository implements MessageRepository {
  final SupabaseClient _client;

  SupabaseMessageRepository(this._client);

  @override
  Future<List<Message>> getMessagesByTalk(String talkId) async {
    final response = await _client
        .from('messages')
        .select('*, profiles(*)')
        .eq('talk_id', talkId)
        .order('created_at', ascending: true);
    
    final List<dynamic> data = response as List<dynamic>;
    return data.map((json) => Message.fromJson(json)).toList();
  }

  @override
  Future<void> sendMessage(Message message) async {
    await _client.from('messages').insert({
      'talk_id': message.talkId,
      'user_id': message.userId,
      'content': message.content,
      'parent_id': message.parentId,
    });
  }

  @override
  Future<void> deleteMessage(String id) async {
    await _client.from('messages').delete().eq('id', id);
  }

  @override
  Stream<List<Message>> watchMessages(String talkId) {
    // Для соответствия интерфейсу, но по ТЗ используем ручное обновление
    return _client
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('talk_id', talkId)
        .order('created_at', ascending: true)
        .map((data) => data.map((json) => Message.fromJson(json)).toList());
  }
}
