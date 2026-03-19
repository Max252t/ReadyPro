import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ready_pro/blocs/auth/auth_bloc.dart';
import 'package:ready_pro/blocs/auth/auth_state.dart';
import 'package:ready_pro/blocs/program/program_bloc.dart';
import 'package:ready_pro/blocs/program/program_event.dart';
import 'package:ready_pro/blocs/program/program_state.dart';
import 'package:ready_pro/blocs/organizer/organizer_bloc.dart';
import 'package:ready_pro/blocs/organizer/organizer_event.dart';
import 'package:ready_pro/blocs/organizer/organizer_state.dart';
import 'package:ready_pro/app/layout/app_breakpoints.dart';
import 'package:ready_pro/core/enums.dart';
import 'package:ready_pro/models/talk.dart';
import 'package:ready_pro/models/task.dart';

import '../../../../../app/routes.dart';
import '../../../../shared/mock/ui_models.dart';
import '../../../../shared/presentation/layout/root_shell.dart';
import '../../../../shared/presentation/widgets/ui_badge.dart';
import '../../../../shared/route_args.dart';

class SpeakerTalksPage extends StatefulWidget {
  final UiRole role;

  const SpeakerTalksPage({super.key, required this.role});

  @override
  State<SpeakerTalksPage> createState() => _SpeakerTalksPageState();
}

class _SpeakerTalksPageState extends State<SpeakerTalksPage> {
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
      context.read<ProgramBloc>().add(FetchSpeakerTalks(
        speakerId: authState.user.id,
        eventId: _eventId!,
      ));
      context.read<OrganizerBloc>().add(FetchOrganizerDashboard(_eventId!));
    }
  }

  Future<void> _openTalkDialog({Talk? editing, required String speakerId}) async {
    if (_eventId == null) return;
    
    final titleController = TextEditingController(text: editing?.title);
    final descController = TextEditingController(text: editing?.description);
    final sectionIdController = TextEditingController(text: editing?.sectionId);
    final roomController = TextEditingController(text: editing?.room);
    final startTimeController = TextEditingController(
      text: editing?.startTime?.toIso8601String() ?? DateTime.now().toIso8601String(),
    );

    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(editing == null ? 'Новый доклад' : 'Редактировать доклад'),
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
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Название доклада'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: descController,
                  maxLines: 4,
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
              final newTalk = Talk(
                id: editing?.id ?? '',
                sectionId: sectionIdController.text,
                speakerId: speakerId,
                title: titleController.text,
                description: descController.text,
                status: editing?.status ?? TalkStatus.draft,
                startTime: DateTime.tryParse(startTimeController.text),
                room: roomController.text,
              );

              if (editing == null) {
                context.read<ProgramBloc>().add(CreateTalk(
                      talk: newTalk,
                      eventId: _eventId!,
                      userId: speakerId,
                    ));
              } else {
                context.read<ProgramBloc>().add(UpdateTalk(
                      talk: newTalk,
                      eventId: _eventId!,
                      userId: speakerId,
                    ));
              }
              Navigator.pop(ctx);
            },
            child: Text(editing == null ? 'Создать' : 'Сохранить'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RootShell(
      role: widget.role,
      title: 'Мои доклады',
      child: BlocBuilder<ProgramBloc, ProgramState>(
        builder: (context, programState) {
          return BlocBuilder<OrganizerBloc, OrganizerState>(
            builder: (context, organizerState) {
              if (programState.isLoading || organizerState is OrganizerLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              final authState = context.read<AuthBloc>().state;
              final userId = authState is AuthAuthenticated ? authState.user.id : '';

              final myTalks = programState.talks.where((t) => t.speakerId == userId).toList();
              final myTasks = organizerState is OrganizerDashboardLoaded
                  ? organizerState.tasks.where((t) => t.assigneeId == userId).toList()
                  : <Task>[];

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Управляйте своими выступлениями',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.6),
                                  ),
                            ),
                          ],
                        ),
                      ),
                      FilledButton.icon(
                        onPressed: () => _openTalkDialog(speakerId: userId),
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Новый доклад'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (myTasks.isNotEmpty) ...[
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Мои задачи от организатора',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            const SizedBox(height: 10),
                            for (final task in myTasks)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Checkbox(
                                      value: task.isCompleted,
                                      onChanged: (val) {
                                        final updatedTask = Task(
                                          id: task.id,
                                          eventId: task.eventId,
                                          assigneeId: task.assigneeId,
                                          assignerId: task.assignerId,
                                          title: task.title,
                                          description: task.description,
                                          dueDate: task.dueDate,
                                          isCompleted: val ?? false,
                                        );
                                        context.read<OrganizerBloc>().add(UpdateTask(updatedTask));
                                      },
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            task.title,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium
                                                ?.copyWith(
                                                  decoration: task.isCompleted
                                                      ? TextDecoration.lineThrough
                                                      : null,
                                                  color: task.isCompleted
                                                      ? Theme.of(context)
                                                          .colorScheme
                                                          .onSurface
                                                          .withValues(alpha: 0.55)
                                                      : null,
                                                ),
                                          ),
                                          if (task.description != null && task.description!.isNotEmpty)
                                            Text(
                                              task.description!,
                                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .onSurface
                                                        .withValues(alpha: 0.6),
                                                  ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (myTalks.isEmpty)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(28),
                        child: Center(
                          child: Text(
                            'У вас пока нет докладов. Создайте свой первый доклад!',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withValues(alpha: 0.6),
                                ),
                          ),
                        ),
                      ),
                    )
                  else
                    LayoutBuilder(
                      builder: (context, c) {
                        final cols =
                            AppBreakpoints.speakerTalkColumns(c.maxWidth);
                        return GridView.count(
                          crossAxisCount: cols,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          childAspectRatio: cols == 2 ? 1.15 : 1.0,
                          children: [
                            for (final talk in myTalks)
                              Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              talk.title,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleSmall
                                                  ?.copyWith(fontWeight: FontWeight.w600),
                                            ),
                                          ),
                                          UiBadge(
                                            talk.status == TalkStatus.ready
                                                ? 'Готов'
                                                : 'Черновик',
                                            variant: talk.status == TalkStatus.ready
                                                ? UiBadgeVariant.defaultFill
                                                : UiBadgeVariant.secondary,
                                          ),
                                        ],
                                      ),
                                      if (talk.description != null && talk.description!.isNotEmpty) ...[
                                        const SizedBox(height: 8),
                                        Text(
                                          talk.description!,
                                          maxLines: 3,
                                          overflow: TextOverflow.ellipsis,
                                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onSurface
                                                    .withValues(alpha: 0.65),
                                              ),
                                        ),
                                      ],
                                      const Spacer(),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Секция ID: ${talk.sectionId}',
                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSurface
                                                  .withValues(alpha: 0.6),
                                            ),
                                      ),
                                      if (talk.startTime != null)
                                        Text(
                                          '${_formatDate(talk.startTime!)}, ${_formatTime(talk.startTime!)}',
                                          style: Theme.of(context).textTheme.bodySmall,
                                        ),
                                      if (talk.room != null)
                                        Text(
                                          talk.room!,
                                          style: Theme.of(context).textTheme.bodySmall,
                                        ),
                                      const SizedBox(height: 10),
                                      Row(
                                        children: [
                                          if (talk.status != TalkStatus.ready)
                                            Expanded(
                                              child: FilledButton.icon(
                                                onPressed: () {
                                                  final updatedTalk = Talk(
                                                    id: talk.id,
                                                    sectionId: talk.sectionId,
                                                    speakerId: talk.speakerId,
                                                    title: talk.title,
                                                    description: talk.description,
                                                    status: TalkStatus.ready,
                                                    startTime: talk.startTime,
                                                    room: talk.room,
                                                  );
                                                  context.read<ProgramBloc>().add(UpdateTalk(
                                                        talk: updatedTalk,
                                                        eventId: _eventId!,
                                                        userId: userId,
                                                      ));
                                                },
                                                icon: const Icon(Icons.check_circle_outline, size: 18),
                                                label: const Text('Готовность'),
                                              ),
                                            ),
                                          if (talk.status != TalkStatus.ready)
                                            const SizedBox(width: 8),
                                          IconButton(
                                            onPressed: () => _openTalkDialog(editing: talk, speakerId: userId),
                                            icon: const Icon(Icons.edit_outlined),
                                          ),
                                          IconButton(
                                            onPressed: () {
                                              context.read<ProgramBloc>().add(DeleteTalk(
                                                    talkId: talk.id,
                                                    eventId: _eventId!,
                                                    userId: userId,
                                                  ));
                                            },
                                            icon: const Icon(Icons.delete_outline),
                                          ),
                                        ],
                                      ),
                                      TextButton(
                                        onPressed: () => Navigator.pushNamed(
                                          context,
                                          AppRoutes.talkDetails,
                                          arguments: {
                                            'role': widget.role,
                                            'talkId': talk.id,
                                            'eventId': _eventId,
                                          },
                                        ),
                                        child: const Text('Подробнее'),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                ],
              );
            },
          );
        },
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
  return '${d.day} ${months[d.month - 1]} ${d.year}';
}
