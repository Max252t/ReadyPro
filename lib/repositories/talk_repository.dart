import 'package:ready_pro/models/talk.dart';

abstract class TalkRepository {
  Future<List<Talk>> getTalksBySection(String sectionId);
  Future<Talk> getTalkById(String id);
  Future<void> createTalk(Talk talk);
  Future<void> updateTalk(Talk talk);
  Future<void> deleteTalk(String id);
}
