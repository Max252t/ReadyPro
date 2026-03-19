import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ready_pro/blocs/auth/auth_bloc.dart';
import 'package:ready_pro/blocs/auth/auth_state.dart';
import 'package:ready_pro/blocs/program/program_bloc.dart';
import 'package:ready_pro/blocs/program/program_event.dart';
import 'package:ready_pro/blocs/program/program_state.dart';
import 'package:ready_pro/core/enums.dart';
import 'package:ready_pro/models/talk.dart';

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
    }
  }

  Future<void> _openAddTalkDialog(BuildContext context, {required String eventId, Talk? talk}) async {
    final titleController = TextEditingController(text: talk?.title);
    final descController = TextEditingController(text: talk?.description);
    final sectionIdController = TextEditingController(text: talk?.sectionId);
    final speakerIdController = TextEditingController(text: talk?.speakerId);
    final roomController = TextEditingController(text: talk?.room);
    final startTimeController = TextEditingController(
      text: talk?.startTime?.toIso8601String() ?? DateTime.now().toIso8601String(),
    );

    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(talk == null ? 'Новый доклад' : 'Редактировать доклад'),
        content: SingleChildScrollView(
          child: SizedBox(
            width: 520,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: sectionIdController,
                  decoration: const InputDecoration(labelText: 'ID Секции'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: speakerIdController,
                  decoration: const InputDecoration(labelText: 'ID Спикера'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Название доклада'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: descController,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'Описание'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: startTimeController,
                  decoration: const InputDecoration(labelText: 'Дата и время (ISO)'),
                ),
                const SizedBox(height: 8),
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
              final authState = context.read<AuthBloc>().state;
              if (authState is! AuthAuthenticated) return;

              final newTalk = Talk(
                id: talk?.id ?? '', // Supabase сгенерирует ID сам
                sectionId: sectionIdController.text,
                speakerId: speakerIdController.text,
                title: titleController.text,
                description: descController.text,
                status: talk?.status ?? TalkStatus.draft,
                startTime: DateTime.tryParse(startTimeController.text),
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
    );
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

    return RootShell(
      role: UiRole.organizer,
      title: 'Наполнение программы',
      child: BlocBuilder<ProgramBloc, ProgramState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.error != null) {
            return Center(child: Text('Ошибка: ${state.error}'));
          }

          final sections = state.sections;
          final talks = state.talks;

          final grouped = sections.map((s) {
            final st = talks.where((t) => t.sectionId == s.id).toList()
              ..sort((a, b) => (a.startTime ?? DateTime.now()).compareTo(b.startTime ?? DateTime.now()));
            return (section: s, talks: st);
          }).toList();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Добавляйте доклады в расписание мероприятия',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.6),
                          ),
                    ),
                  ),
                  FilledButton.icon(
                    onPressed: () => _openAddTalkDialog(context, eventId: _eventId!),
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
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                g.section.name,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ),
                            UiBadge(
                              '${g.talks.length} докладов',
                              variant: UiBadgeVariant.outline,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        if (g.talks.isEmpty)
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 24),
                              child: Text(
                                'Доклады не добавлены',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withValues(alpha: 0.55),
                                    ),
                              ),
                            ),
                          )
                        else
                          for (final talk in g.talks)
                            _TalkRow(
                              talk: talk,
                              onEdit: () => _openAddTalkDialog(context, eventId: _eventId!, talk: talk),
                              onDelete: () {
                                final authState = context.read<AuthBloc>().state;
                                if (authState is AuthAuthenticated) {
                                  context.read<ProgramBloc>().add(DeleteTalk(
                                        talkId: talk.id,
                                        eventId: _eventId!,
                                        userId: authState.user.id,
                                      ));
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
    );
  }
}

class _TalkRow extends StatelessWidget {
  final Talk talk;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _TalkRow({
    required this.talk,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
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
                child: Text(
                  talk.title,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 20),
                    onPressed: onEdit,
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 20),
                    onPressed: onDelete,
                  ),
                  const SizedBox(width: 8),
                  UiBadge(
                    talk.status == TalkStatus.ready ? 'Готов' : 'Черновик',
                    variant: talk.status == TalkStatus.ready
                        ? UiBadgeVariant.defaultFill
                        : UiBadgeVariant.secondary,
                  ),
                ],
              ),
            ],
          ),
          if (talk.description != null && talk.description!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              talk.description!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.6),
                  ),
            ),
          ],
          const SizedBox(height: 8),
          Wrap(
            spacing: 16,
            runSpacing: 6,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.person_outline, size: 16, color: Theme.of(context).hintColor),
                  const SizedBox(width: 4),
                  Text('ID Спикера: ${talk.speakerId}', style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
              if (talk.startTime != null)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.schedule, size: 16, color: Theme.of(context).hintColor),
                    const SizedBox(width: 4),
                    Text(
                      '${_formatDate(talk.startTime!)}, ${_formatTime(talk.startTime!)}',
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

String _formatTime(DateTime d) {
  final hh = d.hour.toString().padLeft(2, '0');
  final mm = d.minute.toString().padLeft(2, '0');
  return '$hh:$mm';
}

String _formatDate(DateTime d) {
  const months = [
    'января', 'февраля', 'марта', 'апреля', 'мая', 'июня',
    'июля', 'августа', 'сентября', 'октября', 'ноября', 'декабря',
  ];
  return '${d.day} ${months[d.month - 1]}';
}
