import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ready_pro/blocs/auth/auth_bloc.dart';
import 'package:ready_pro/blocs/auth/auth_state.dart';
import 'package:ready_pro/blocs/program/program_bloc.dart';
import 'package:ready_pro/blocs/program/program_event.dart';
import 'package:ready_pro/blocs/program/program_state.dart';
import 'package:ready_pro/models/talk.dart';
import 'package:ready_pro/models/section.dart';

import '../../../../../app/routes.dart';
import '../../../../shared/mock/ui_models.dart';
import '../../../../shared/presentation/layout/root_shell.dart';

class MySchedulePage extends StatefulWidget {
  final UiRole role;

  const MySchedulePage({super.key, required this.role});

  @override
  State<MySchedulePage> createState() => _MySchedulePageState();
}

class _MySchedulePageState extends State<MySchedulePage> {
  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      // Для MVP предполагаем, что у нас одно активное мероприятие.
      // В реальном приложении eventId приходил бы из аргументов или глобального состояния.
      // Здесь используем заглушку для ID, которую должен обработать репозиторий.
      context.read<ProgramBloc>().add(FetchProgram(
        eventId: '00000000-0000-0000-0000-000000000000', // Будет заменено на реальный ID в будущем
        userId: authState.user.id,
      ));
    }
  }

  void _remove(String talkId) {
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
      child: BlocBuilder<ProgramBloc, ProgramState>(
        builder: (context, state) {
          if (state.isLoading) return const Center(child: CircularProgressIndicator());

          // Фильтруем только те доклады, которые есть в расписании пользователя
          final talksInSchedule = state.talks
              .where((t) => state.scheduleTalkIds.contains(t.id))
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

          return Column(
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
                            section: state.sections
                                .where((s) => s.id == talk.sectionId)
                                .firstOrNull,
                            role: widget.role,
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
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Text(
              'Ваше расписание пусто',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => Navigator.pushReplacementNamed(
                context,
                AppRoutes.participantProgram,
                arguments: {'role': widget.role},
              ),
              child: const Text('Перейти к программе'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScheduleTalkTile extends StatelessWidget {
  final Talk talk;
  final Section? section;
  final UiRole role;
  final VoidCallback onRemove;

  const _ScheduleTalkTile({
    required this.talk,
    required this.section,
    required this.role,
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
                    arguments: {'role': role, 'talkId': talk.id},
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
