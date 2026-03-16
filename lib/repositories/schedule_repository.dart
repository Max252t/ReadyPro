import 'package:ready_pro/models/talk.dart';

abstract class ScheduleRepository {
  Future<List<Talk>> getUserSchedule(String userId);
  Future<void> addToSchedule(String userId, String talkId);
  Future<void> removeFromSchedule(String userId, String talkId);
  Future<bool> isInSchedule(String userId, String talkId);
}
