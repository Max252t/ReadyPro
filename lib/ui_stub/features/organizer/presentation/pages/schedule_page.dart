import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ready_pro/blocs/auth/auth_bloc.dart';
import 'package:ready_pro/blocs/auth/auth_state.dart';
import 'package:ready_pro/blocs/program/program_bloc.dart';
import 'package:ready_pro/blocs/program/program_event.dart';
import 'package:ready_pro/blocs/program/program_state.dart';
import 'package:ready_pro/blocs/event/event_bloc.dart';
import 'package:ready_pro/blocs/event/event_event.dart';
import 'package:ready_pro/blocs/event/event_state.dart';
import 'package:ready_pro/core/enums.dart';
import 'package:ready_pro/models/talk.dart';
import 'package:ready_pro/models/section.dart';
import 'package:ready_pro/models/user.dart';

import '../../../../shared/mock/ui_models.dart';
import '../../../../shared/presentation/layout/root_shell.dart';
import '../../../../shared/presentation/widgets/ui_badge.dart';
import '../../../../shared/route_args.dart';

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  String? _eventId;
  List<Profile> _allParticipants = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final newEventId = eventIdFromArgs(ModalRoute.of(context)?.settings.arguments);
    if (newEventId != null && newEventId.isNotEmpty && _eventId != newEventId) {
      _eventId = newEventId;
      _refreshData();
    }
  }

  void _refreshData() {
    if (_eventId == null) return;
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<ProgramBloc>().add(FetchProgram(
            eventId: _eventId!,
            userId: authState.user.id,
          ));
      context.read<EventBloc>().add(LoadEventParticipants(_eventId!));
    }
  }

  Future<void> _openAddTalkDialog(BuildContext context, {required String eventId, Talk? talk, required List<Section> sections}) async {
    final titleController = TextEditingController(text: talk?.title);
    final descController = TextEditingController(text: talk?.description);
    final roomController = TextEditingController(text: talk?.room);
    
    Section? selectedSection = talk?.sectionId != null 
        ? sections.cast<Section?>().firstWhere((s) => s?.id == talk!.sectionId, orElse: () => null)
        : sections.isNotEmpty ? sections.first : null;
        
    Profile? selectedSpeaker = talk?.speakerId != null
        ? _allParticipants.cast<Profile?>().firstWhere((p) => p?.id == talk!.speakerId, orElse: () => null)
        : null;

    DateTime selectedDate = talk?.startTime ?? DateTime.now();
    TimeOfDay selectedTime = TimeOfDay.fromDateTime(selectedDate);

    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(talk == null ? 'Новый доклад' : 'Редактировать доклад'),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 520,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<Section>(
                    value: selectedSection,
                    decoration: const InputDecoration(labelText: 'Секция'),
                    items: sections.map((s) => DropdownMenuItem(value: s, child: Text(s.name))).toList(),
                    onChanged: (val) => setDialogState(() => selectedSection = val),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<Profile>(
                    value: selectedSpeaker,
                    decoration: const InputDecoration(labelText: 'Спикер (поиск по имени)'),
                    items: _allParticipants.map((p) => DropdownMenuItem(value: p, child: Text(p.fullName))).toList(),
                    onChanged: (val) => setDialogState(() => selectedSpeaker = val),
                    hint: const Text('Выберите спикера'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(labelText: 'Название доклада'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: descController,
                    maxLines: 2,
                    decoration: const InputDecoration(labelText: 'Описание'),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: selectedDate,
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2030),
                            );
                            if (date != null) setDialogState(() => selectedDate = date);
                          },
                          icon: const Icon(Icons.calendar_today, size: 18),
                          label: Text(_formatDate(selectedDate)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            final time = await showTimePicker(
                              context: context,
                              initialTime: selectedTime,
                            );
                            if (time != null) setDialogState(() => selectedTime = time);
                          },
                          icon: const Icon(Icons.access_time, size: 18),
                          label: Text(selectedTime.format(context)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: roomController,
                    decoration: const InputDecoration(labelText: 'Зал'),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Отмена')),
            FilledButton(
              onPressed: () {
                if (selectedSection == null || selectedSpeaker == null) return;
                
                final authState = context.read<AuthBloc>().state;
                if (authState is! AuthAuthenticated) return;

                final startTime = DateTime(
                  selectedDate.year,
                  selectedDate.month,
                  selectedDate.day,
                  selectedTime.hour,
                  selectedTime.minute,
                );

                final newTalk = Talk(
                  id: talk?.id ?? '',
                  sectionId: selectedSection!.id,
                  speakerId: selectedSpeaker!.id,
                  title: titleController.text,
                  description: descController.text,
                  status: talk?.status ?? TalkStatus.draft,
                  startTime: startTime,
                  room: roomController.text,
                );

                if (talk == null) {
                  context.read<ProgramBloc>().add(CreateTalk(
                        talk: newTalk,
                        eventId: eventId,
                        userId: authState.user.id,
                      ));
                } else {
                  context.read<ProgramBloc>().add(UpdateTalk(
                        talk: newTalk,
                        eventId: eventId,
                        userId: authState.user.id,
                      ));
                }
                Navigator.pop(ctx);
              },
              child: Text(talk == null ? 'Добавить' : 'Сохранить'),
            ),
          ],
        ),
      ),
    );
  }

  String _getSpeakerName(String id) {
    try {
      return _allParticipants.firstWhere((p) => p.id == id).fullName;
    } catch (_) {
      return 'Спикер не найден';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_eventId == null) {
      return const RootShell(
        role: UiRole.organizer,
        title: 'Наполнение программы',
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return BlocListener<EventBloc, EventState>(
      listener: (context, state) {
        if (state is EventParticipantsLoaded) {
          setState(() => _allParticipants = state.participants);
        }
      },
      child: RootShell(
        role: UiRole.organizer,
        title: 'Наполнение программы',
        child: BlocBuilder<ProgramBloc, ProgramState>(
          builder: (context, state) {
            if (state.isLoading) return const Center(child: CircularProgressIndicator());
            
            final grouped = state.sections.map((s) {
              final st = state.talks.where((t) => t.sectionId == s.id).toList()
                ..sort((a, b) => (a.startTime ?? DateTime.now()).compareTo(b.startTime ?? DateTime.now()));
              return (section: s, talks: st);
            }).toList();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(child: Text('Управляйте расписанием докладов')),
                    FilledButton.icon(
                      onPressed: () => _openAddTalkDialog(context, eventId: _eventId!, sections: state.sections),
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Добавить доклад'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                for (final g in grouped) ...[
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(g.section.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                          const Divider(),
                          if (g.talks.isEmpty) const Center(child: Text('Нет докладов'))
                          else
                            for (final talk in g.talks)
                              _TalkRow(
                                talk: talk,
                                speakerName: _getSpeakerName(talk.speakerId),
                                onEdit: () => _openAddTalkDialog(context, eventId: _eventId!, talk: talk, sections: state.sections),
                                onDelete: () {
                                  final authState = context.read<AuthBloc>().state;
                                  if (authState is AuthAuthenticated) {
                                    context.read<ProgramBloc>().add(DeleteTalk(talkId: talk.id, eventId: _eventId!, userId: authState.user.id));
                                  }
                                },
                              ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

class _TalkRow extends StatelessWidget {
  final Talk talk;
  final String speakerName;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _TalkRow({required this.talk, required this.speakerName, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(talk.title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Спикер: $speakerName'),
          if (talk.startTime != null) Text('Время: ${_formatDate(talk.startTime!)}, ${_formatTime(talk.startTime!)}'),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(icon: const Icon(Icons.edit, size: 20), onPressed: onEdit),
          IconButton(icon: const Icon(Icons.delete, size: 20), onPressed: onDelete),
        ],
      ),
    );
  }
}

String _formatTime(DateTime d) => '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
String _formatDate(DateTime d) => '${d.day}.${d.month}.${d.year}';
