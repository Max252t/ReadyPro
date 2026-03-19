import 'package:equatable/equatable.dart';
import 'package:ready_pro/models/feedback.dart';
import 'package:ready_pro/models/message.dart';

abstract class TalkEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchTalkDetails extends TalkEvent {
  final String talkId;
  FetchTalkDetails(this.talkId);
  @override
  List<Object?> get props => [talkId];
}

class SendMessageRequested extends TalkEvent {
  final Message message;
  SendMessageRequested(this.message);
  @override
  List<Object?> get props => [message];
}

class SubmitFeedbackRequested extends TalkEvent {
  final Feedback feedback;
  SubmitFeedbackRequested(this.feedback);
  @override
  List<Object?> get props => [feedback];
}
