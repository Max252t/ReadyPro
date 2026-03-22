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
import 'package:ready_pro/models/talk.dart';
import 'package:ready_pro/models/section.dart';
import 'package:ready_pro/models/user_event.dart';

import '../../../../../app/routes.dart';
import '../../../../shared/mock/ui_models.dart';
import '../../../../shared/presentation/layout/root_shell.dart';
import '../../../../shared/route_args.dart';

class MySchedulePage extends StatefulWidget {
  final UiRole role;

  const MySchedulePage({super.key, required this.role});

  @override
  State<MySchedulePage> createState() => _MySchedulePageState();
}

class _MySchedulePageState extends State<MySchedulePage> {
  String? _selectedEventId;

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final newEventId = eventIdFromArgs(ModalRoute.of(context)?.settings.arguments);
    if (newEventId != null && newEventId.isNotEmpty && _selectedEventId == null) {
      setState(() {
        _selectedEventId = newEventId;
      });
      _refreshProgram();
    }
  }

  void _loadEvents() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<EventBloc>().add(LoadMyEvents(authState.user.id));
    }
  }

  void _refreshProgram() {
    if (_selectedEventId == null) return;
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<ProgramBloc>().add(FetchProgram(
        eventId: _selectedEventId!,
        userId: authState.user.id,
      ));
    }
  }

  void _remove(String talkId) {
    if (_selectedEventId == null) return;
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<ProgramBloc>().add(ToggleScheduleRequested(
        talkId: talkId,
        userId: authState.user.id,
      ));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Удалено из вашего расписания')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return RootShell(
      role: widget.role,
      title: 'Моё расписание',
      child: BlocBuilder<EventBloc, EventState>(
        builder: (context, eventState) {
          List<UserEvent> myEvents = [];
          if (eventState is EventsLoaded) {
            myEvents = eventState.events;
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildEventSelector(myEvents),
              const SizedBox(height: 16),
              Expanded(
                child: BlocBuilder<ProgramBloc, ProgramState>(
                  builder: (context, programState) {
                    if (programState.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (_selectedEventId == null) {
                      return _buildNoEventState();
                    }

                    final talksInSchedule = programState.talks
                        .where((t) => programState.scheduleTalkIds.contains(t.id))
                        .toList()
                      ..sort((a, b) => a.startTime?.compareTo(b.startTime ?? DateTime.now()) ?? 0);

                    if (talksInSchedule.isEmpty) {
                      return _buildEmptyState();
                    }

                    final grouped = <String, List<Talk>>{};
                    for (final t in talksInSchedule) {
                      if (t.startTime == null) continue;
                      final k = _dateKeyRu(t.startTime!);
                      grouped.putIfAbsent(k, () => []).add(t);
                    }

                    final entries = grouped.entries.toList()
                      ..sort((a, b) => a.value.first.startTime!.compareTo(b.value.first.startTime!));

                    return SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Доклады, которые вы планируете посетить',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                                ),
                          ),
                          const SizedBox(height: 16),
                          for (final e in entries) ...[
                            Card(
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _weekdayLong(e.value.first.startTime!),
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                    const SizedBox(height: 12),
                                    for (final talk in e.value)
                                      _ScheduleTalkTile(
                                        talk: talk,
                                        section: programState.sections
                                            .where((s) => s.id == talk.sectionId)
                                            .firstOrNull,
                                        role: widget.role,
                                        eventId: _selectedEventId,
                                        onRemove: () => _remove(talk.id),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                          ],
                          Card(
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.06),
                            child: Padding(
                              padding: const EdgeInsets.all(18),
                              child: Center(
                                child: Text(
                                  'Всего докладов в расписании: ${talksInSchedule.length}',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                                      ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEventSelector(List<UserEvent> events) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: _selectedEventId,
          hint: const Text('Выберите мероприятие'),
          items: events.map((e) {
            return DropdownMenuItem(
              value: e.eventId,
              child: Text(e.title, maxLines: 1, overflow: TextOverflow.ellipsis),
            );
          }).toList(),
          onChanged: (val) {
            if (val != null) {
              setState(() {
                _selectedEventId = val;
              });
              _refreshProgram();
            }
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.calendar_today_outlined, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                'Ваше расписание для этого мероприятия пусто',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => Navigator.pushReplacementNamed(
                  context,
                  AppRoutes.participantProgram,
                  arguments: {'role': widget.role, 'eventId': _selectedEventId},
                ),
                child: const Text('Перейти к программе'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNoEventState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.event_busy, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'Выберите мероприятие в списке выше,\nчтобы увидеть свое расписание',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pushReplacementNamed(
              context,
              AppRoutes.allEvents,
              arguments: {'role': widget.role},
            ),
            child: const Text('Посмотреть все мероприятия'),
          ),
        ],
      ),
    );
  }
}

class _ScheduleTalkTile extends StatelessWidget {
  final Talk talk;
  final Section? section;
  final UiRole role;
  final String? eventId;
  final VoidCallback onRemove;

  const _ScheduleTalkTile({
    required this.talk,
    required this.section,
    required this.role,
    this.eventId,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => Navigator.pushNamed(
                    context,
                    AppRoutes.talkDetails,
                    arguments: {'role': role, 'talkId': talk.id, 'eventId': eventId},
                  ),
                  child: Text(
                    talk.title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                        ),
                  ),
                ),
              ),
              IconButton(
                onPressed: onRemove,
                icon: const Icon(Icons.close, size: 20),
                tooltip: 'Убрать',
              ),
            ],
          ),
          if (section != null)
            Text(
              section!.name,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
            ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 14,
            runSpacing: 6,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.schedule, size: 16, color: Theme.of(context).hintColor),
                  const SizedBox(width: 4),
                  Text(
                    '${talk.startTime != null ? _formatTime(talk.startTime!) : '--:--'}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              if (talk.room != null)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.place_outlined, size: 16, color: Theme.of(context).hintColor),
                    const SizedBox(width: 4),
                    Text(talk.room!, style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }
}

String _dateKeyRu(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';

String _weekdayLong(DateTime d) {
  const w = [
    'понедельник', 'вторник', 'среда', 'четверг', 'пятница', 'суббота', 'воскресенье',
  ];
  const months = [
    'января', 'февраля', 'марта', 'апреля', 'мая', 'июня',
    'июля', 'августа', 'сентября', 'октября', 'ноября', 'декабря',
  ];
  return '${w[d.weekday - 1]}, ${d.day} ${months[d.month - 1]}';
}

String _formatTime(DateTime d) {
  final hh = d.hour.toString().padLeft(2, '0');
  final mm = d.minute.toString().padLeft(2, '0');
  return '$hh:$mm';
}

extension _FirstOrNull<E> on Iterable<E> {
  E? get firstOrNull {
    final it = iterator;
    return it.moveNext() ? it.current : null;
  }
}
