import 'package:equatable/equatable.dart';
import 'package:ready_pro/models/section.dart';

abstract class CuratorEvent extends Equatable {
  const CuratorEvent();

  @override
  List<Object?> get props => [];
}

class FetchCuratorSection extends CuratorEvent {
  final String userId;
  final String eventId;

  const FetchCuratorSection({required this.userId, required this.eventId});

  @override
  List<Object?> get props => [userId, eventId];
}

class UpdateSectionProgress extends CuratorEvent {
  final Section section;
  final int progress;

  const UpdateSectionProgress({required this.section, required this.progress});

  @override
  List<Object?> get props => [section, progress];
}

class SubmitFinalReport extends CuratorEvent {
  final Section section;
  final String reportText;

  const SubmitFinalReport({required this.section, required this.reportText});

  @override
  List<Object?> get props => [section, reportText];
}
