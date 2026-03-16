import 'package:ready_pro/models/feedback.dart';

abstract class FeedbackRepository {
  Future<List<Feedback>> getFeedbackByTalk(String talkId);
  Future<void> submitFeedback(Feedback feedback);
  Future<void> updateFeedback(Feedback feedback);
  Future<void> deleteFeedback(String id);
}
