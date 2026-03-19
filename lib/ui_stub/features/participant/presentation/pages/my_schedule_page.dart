import 'package:flutter/material.dart';

import '../../../../../app/routes.dart';
import '../../../../shared/mock/ui_mock_data.dart';
import '../../../../shared/mock/ui_models.dart';
import '../../../../shared/presentation/layout/root_shell.dart';

class MySchedulePage extends StatefulWidget {
  final UiRole role;

  const MySchedulePage({super.key, required this.role});

  @override
  State<MySchedulePage> createState() => _MySchedulePageState();
}

class _MySchedulePageState extends State<MySchedulePage> {
  late Set<String> _scheduleTalkIds;

  @override
  void initState() {
    super.initState();
    final uid = UiMockData.userForRole(widget.role).id;
    _scheduleTalkIds = UiMockData.schedule
        .where((s) => s.userId == uid)
        .map((s) => s.talkId)
        .toSet();
  }

  void _remove(String talkId) {
    setState(() => _scheduleTalkIds.remove(talkId));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Удалено из расписания (заглушка)')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final talks = _scheduleTalkIds
        .map((id) => UiMockData.talks.where((t) => t.id == id).firstOrNull)
        .whereType<UiTalk>()
        .toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));

    final grouped = <String, List<UiTalk>>{};
    for (final t in talks) {
      final k = _dateKeyRu(t.startTime);
      grouped.putIfAbsent(k, () => []).add(t);
    }
    final entries = grouped.entries.toList()
      ..sort((a, b) => a.value.first.startTime.compareTo(b.value.first.startTime));

    final speakers =
        UiMockData.users.where((u) => u.role == UiRole.speaker).toList();

    return RootShell(
      role: widget.role,
      title: 'Моё расписание',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Доклады, которые вы планируете посетить',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.6),
                ),
          ),
          const SizedBox(height: 16),
          if (talks.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Text(
                      'Ваше расписание пусто',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.6),
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
            )
          else ...[
            for (final e in entries) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _weekdayLong(e.value.first.startTime),
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: 12),
                      for (final talk in e.value)
                        _ScheduleTalkTile(
                          talk: talk,
                          speaker:
                              speakers.where((u) => u.id == talk.speakerId).firstOrNull,
                          section: UiMockData.sections
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
                child: Text(
                  'Всего докладов в расписании: ${talks.length}',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.7),
                      ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ScheduleTalkTile extends StatelessWidget {
  final UiTalk talk;
  final UiUser? speaker;
  final UiSection? section;
  final UiRole role;
  final VoidCallback onRemove;

  const _ScheduleTalkTile({
    required this.talk,
    required this.speaker,
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
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.6),
                  ),
            ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 14,
            runSpacing: 6,
            children: [
              if (speaker != null)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.person_outline, size: 16, color: Theme.of(context).hintColor),
                    const SizedBox(width: 4),
                    Text(speaker!.name, style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.schedule, size: 16, color: Theme.of(context).hintColor),
                  const SizedBox(width: 4),
                  Text(
                    '${_formatTime(talk.startTime)} (${talk.durationMin} мин)',
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
