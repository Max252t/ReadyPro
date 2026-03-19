import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ready_pro/repositories/talk_repository.dart';
import 'package:ready_pro/repositories/section_repository.dart';
import 'package:ready_pro/repositories/auth_repository.dart';
import 'package:ready_pro/repositories/message_repository.dart';
import 'package:ready_pro/repositories/feedback_repository.dart';
import 'package:ready_pro/models/user.dart';
import 'talk_event.dart';
import 'talk_state.dart';

class TalkBloc extends Bloc<TalkEvent, TalkState> {
  final TalkRepository _talkRepository;
  final SectionRepository _sectionRepository;
  final AuthRepository _authRepository;
  final MessageRepository _messageRepository;
  final FeedbackRepository _feedbackRepository;

  TalkBloc({
    required TalkRepository talkRepository,
    required SectionRepository sectionRepository,
    required AuthRepository authRepository,
    required MessageRepository messageRepository,
    required FeedbackRepository feedbackRepository,
  })  : _talkRepository = talkRepository,
        _sectionRepository = sectionRepository,
        _authRepository = authRepository,
        _messageRepository = messageRepository,
        _feedbackRepository = feedbackRepository,
        super(const TalkState()) {
    on<FetchTalkDetails>(_onFetchTalkDetails);
    on<SendMessageRequested>(_onSendMessage);
    on<SubmitFeedbackRequested>(_onSubmitFeedback);
  }

  Future<void> _onFetchTalkDetails(FetchTalkDetails event, Emitter<TalkState> emit) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final talk = await _talkRepository.getTalkById(event.talkId);
      final section = await _sectionRepository.getSectionById(talk.sectionId);
      
      // Загружаем спикера (профиль по ID)
      // В MVP мы можем расширить AuthRepository или использовать существующий метод
      // Для простоты предположим, что у нас есть доступ к профилям
      // В реальном приложении это мог бы быть UserRepository
      
      final messages = await _messageRepository.getMessagesByTalk(event.talkId);
      final feedbacks = await _feedbackRepository.getFeedbackByTalk(event.talkId);

      emit(state.copyWith(
        isLoading: false,
        talk: talk,
        section: section,
        messages: messages,
        feedback: feedbacks,
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> _onSendMessage(SendMessageRequested event, Emitter<TalkState> emit) async {
    try {
      await _messageRepository.sendMessage(event.message);
      final messages = await _messageRepository.getMessagesByTalk(event.message.talkId);
      emit(state.copyWith(messages: messages));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> _onSubmitFeedback(SubmitFeedbackRequested event, Emitter<TalkState> emit) async {
    try {
      await _feedbackRepository.submitFeedback(event.feedback);
      final feedbacks = await _feedbackRepository.getFeedbackByTalk(event.feedback.talkId);
      emit(state.copyWith(feedback: feedbacks, successMessage: 'Отзыв успешно отправлен'));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }
}
