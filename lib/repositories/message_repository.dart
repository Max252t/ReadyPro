import 'package:ready_pro/models/message.dart';

abstract class MessageRepository {
  Future<List<Message>> getMessagesByTalk(String talkId);
  Future<void> sendMessage(Message message);
  Future<void> deleteMessage(String id);
  Stream<List<Message>> watchMessages(String talkId);
}
