import 'package:equatable/equatable.dart';
import 'package:ready_pro/models/talk.dart';
import 'package:ready_pro/models/message.dart';
import 'package:ready_pro/models/feedback.dart';
import 'package:ready_pro/models/section.dart';
import 'package:ready_pro/models/user.dart';

class TalkState extends Equatable {
  final bool isLoading;
  final Talk? talk;
  final Section? section;
  final Profile? speaker;
  final List<Message> messages;
  final List<Feedback> feedback;
  final String? error;
  final String? successMessage;

  const TalkState({
    this.isLoading = false,
    this.talk,
    this.section,
    this.speaker,
    this.messages = const [],
    this.feedback = const [],
    this.error,
    this.successMessage,
  });

  TalkState copyWith({
    bool? isLoading,
    Talk? talk,
    Section? section,
    Profile? speaker,
    List<Message>? messages,
    List<Feedback>? feedback,
    String? error,
    String? successMessage,
  }) {
    return TalkState(
      isLoading: isLoading ?? this.isLoading,
      talk: talk ?? this.talk,
      section: section ?? this.section,
      speaker: speaker ?? this.speaker,
      messages: messages ?? this.messages,
      feedback: feedback ?? this.feedback,
      error: error,
      successMessage: successMessage,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        talk,
        section,
        speaker,
        messages,
        feedback,
        error,
        successMessage,
      ];
}
