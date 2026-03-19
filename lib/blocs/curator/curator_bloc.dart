import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ready_pro/repositories/section_repository.dart';
import 'package:ready_pro/repositories/talk_repository.dart';
import 'package:ready_pro/models/section.dart';
import 'curator_event.dart';
import 'curator_state.dart';

class CuratorBloc extends Bloc<CuratorEvent, CuratorState> {
  final SectionRepository sectionRepository;
  final TalkRepository talkRepository;

  CuratorBloc({
    required this.sectionRepository,
    required this.talkRepository,
  }) : super(CuratorInitial()) {
    on<FetchCuratorSection>(_onFetchCuratorSection);
    on<UpdateSectionProgress>(_onUpdateSectionProgress);
    on<SubmitFinalReport>(_onSubmitFinalReport);
  }

  Future<void> _onFetchCuratorSection(
    FetchCuratorSection event,
    Emitter<CuratorState> emit,
  ) async {
    emit(CuratorLoading());
    try {
      final sections = await sectionRepository.getSectionsByEvent(event.eventId);
      // Находим секцию, за которой закреплен данный куратор
      final curatorSection = sections.firstWhere(
        (s) => s.curatorId == event.userId,
        orElse: () => throw Exception('Секция для данного куратора не найдена'),
      );

      final talks = await talkRepository.getTalksBySection(curatorSection.id);

      emit(CuratorSectionLoaded(
        section: curatorSection,
        talks: talks,
      ));
    } catch (e) {
      emit(CuratorError(e.toString()));
    }
  }

  Future<void> _onUpdateSectionProgress(
    UpdateSectionProgress event,
    Emitter<CuratorState> emit,
  ) async {
    try {
      final updatedSection = Section(
        id: event.section.id,
        eventId: event.section.eventId,
        name: event.section.name,
        description: event.section.description,
        curatorId: event.section.curatorId,
        progress: event.progress,
        finalReport: event.section.finalReport,
      );

      await sectionRepository.updateSection(updatedSection);
      add(FetchCuratorSection(
        userId: event.section.curatorId!,
        eventId: event.section.eventId,
      ));
    } catch (e) {
      emit(CuratorError(e.toString()));
    }
  }

  Future<void> _onSubmitFinalReport(
    SubmitFinalReport event,
    Emitter<CuratorState> emit,
  ) async {
    try {
      final updatedSection = Section(
        id: event.section.id,
        eventId: event.section.eventId,
        name: event.section.name,
        description: event.section.description,
        curatorId: event.section.curatorId,
        progress: event.section.progress,
        finalReport: event.reportText,
      );

      await sectionRepository.updateSection(updatedSection);
      add(FetchCuratorSection(
        userId: event.section.curatorId!,
        eventId: event.section.eventId,
      ));
    } catch (e) {
      emit(CuratorError(e.toString()));
    }
  }
}
