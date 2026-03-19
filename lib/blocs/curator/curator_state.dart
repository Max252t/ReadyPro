import 'package:equatable/equatable.dart';
import 'package:ready_pro/models/section.dart';
import 'package:ready_pro/models/talk.dart';

abstract class CuratorState extends Equatable {
  const CuratorState();
  
  @override
  List<Object?> get props => [];
}

class CuratorInitial extends CuratorState {}

class CuratorLoading extends CuratorState {}

class CuratorSectionLoaded extends CuratorState {
  final Section section;
  final List<Talk> talks;

  const CuratorSectionLoaded({
    required this.section,
    required this.talks,
  });

  @override
  List<Object?> get props => [section, talks];
}

class CuratorError extends CuratorState {
  final String message;

  const CuratorError(this.message);

  @override
  List<Object?> get props => [message];
}
