import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ready_pro/models/talk.dart';
import 'package:ready_pro/repositories/section_repository.dart';
import 'package:ready_pro/repositories/talk_repository.dart';
import 'package:ready_pro/repositories/schedule_repository.dart';
import 'package:ready_pro/repositories/auth_repository.dart';
import 'program_event.dart';
import 'program_state.dart';

class ProgramBloc extends Bloc<ProgramEvent, ProgramState> {
  final SectionRepository _sectionRepository;
  final TalkRepository _talkRepository;
  final ScheduleRepository _scheduleRepository;
  final AuthRepository _authRepository;

  ProgramBloc({
    required SectionRepository sectionRepository,
    required TalkRepository talkRepository,
    required ScheduleRepository scheduleRepository,
    required AuthRepository authRepository,
  })  : _sectionRepository = sectionRepository,
        _talkRepository = talkRepository,
        _scheduleRepository = scheduleRepository,
        _authRepository = authRepository,
        super(const ProgramState()) {
    on<FetchProgram>(_onFetchProgram);
    on<FetchSpeakerTalks>(_onFetchSpeakerTalks);
    on<ToggleScheduleRequested>(_onToggleSchedule);
    on<CreateTalk>(_onCreateTalk);
    on<UpdateTalk>(_onUpdateTalk);
    on<DeleteTalk>(_onDeleteTalk);
  }

  Future<void> _onFetchProgram(FetchProgram event, Emitter<ProgramState> emit) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final sections = await _sectionRepository.getSectionsByEvent(event.eventId);
      
      final allTalks = <Talk>[];
      for (final section in sections) {
        final sectionTalks = await _talkRepository.getTalksBySection(section.id);
        allTalks.addAll(sectionTalks);
      }

      final scheduleTalks = await _scheduleRepository.getUserSchedule(event.userId);
      final scheduleIds = scheduleTalks.map((t) => t.id).toSet();

      emit(state.copyWith(
        isLoading: false,
        sections: sections,
        talks: allTalks,
        scheduleTalkIds: scheduleIds,
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> _onFetchSpeakerTalks(FetchSpeakerTalks event, Emitter<ProgramState> emit) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final sections = await _sectionRepository.getSectionsByEvent(event.eventId);
      
      final allTalks = <Talk>[];
      for (final section in sections) {
        final sectionTalks = await _talkRepository.getTalksBySection(section.id);
        allTalks.addAll(sectionTalks.where((t) => t.speakerId == event.speakerId));
      }

      emit(state.copyWith(
        isLoading: false,
        sections: sections,
        talks: allTalks,
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> _onToggleSchedule(ToggleScheduleRequested event, Emitter<ProgramState> emit) async {
    final isCurrentlyIn = state.scheduleTalkIds.contains(event.talkId);
    final newIds = Set<String>.from(state.scheduleTalkIds);
    
    try {
      if (isCurrentlyIn) {
        newIds.remove(event.talkId);
        await _scheduleRepository.removeFromSchedule(event.userId, event.talkId);
      } else {
        newIds.add(event.talkId);
        await _scheduleRepository.addToSchedule(event.userId, event.talkId);
      }
      emit(state.copyWith(scheduleTalkIds: newIds));
    } catch (e) {
      // Можно добавить отдельное состояние ошибки для уведомления
    }
  }

  Future<void> _onCreateTalk(CreateTalk event, Emitter<ProgramState> emit) async {
    try {
      await _talkRepository.createTalk(event.talk);
      add(FetchProgram(eventId: event.eventId, userId: event.userId));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> _onUpdateTalk(UpdateTalk event, Emitter<ProgramState> emit) async {
    try {
      await _talkRepository.updateTalk(event.talk);
      add(FetchProgram(eventId: event.eventId, userId: event.userId));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> _onDeleteTalk(DeleteTalk event, Emitter<ProgramState> emit) async {
    try {
      await _talkRepository.deleteTalk(event.talkId);
      add(FetchProgram(eventId: event.eventId, userId: event.userId));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }
}
