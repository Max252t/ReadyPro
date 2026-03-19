import 'package:equatable/equatable.dart';
import 'package:ready_pro/models/section.dart';
import 'package:ready_pro/models/talk.dart';
import 'package:ready_pro/models/user.dart';

class ProgramState extends Equatable {
  final bool isLoading;
  final List<Section> sections;
  final List<Talk> talks;
  final List<Profile> speakers;
  final Set<String> scheduleTalkIds;
  final String? error;

  const ProgramState({
    this.isLoading = false,
    this.sections = const [],
    this.talks = const [],
    this.speakers = const [],
    this.scheduleTalkIds = const {},
    this.error,
  });

  ProgramState copyWith({
    bool? isLoading,
    List<Section>? sections,
    List<Talk>? talks,
    List<Profile>? speakers,
    Set<String>? scheduleTalkIds,
    String? error,
  }) {
    return ProgramState(
      isLoading: isLoading ?? this.isLoading,
      sections: sections ?? this.sections,
      talks: talks ?? this.talks,
      speakers: speakers ?? this.speakers,
      scheduleTalkIds: scheduleTalkIds ?? this.scheduleTalkIds,
      error: error,
    );
  }

  @override
  List<Object?> get props => [isLoading, sections, talks, speakers, scheduleTalkIds, error];
}
