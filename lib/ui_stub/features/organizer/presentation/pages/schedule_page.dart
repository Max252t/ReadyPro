import 'package:flutter/material.dart';

import '../../../../shared/mock/ui_mock_data.dart';
import '../../../../shared/mock/ui_models.dart';
import '../../../../shared/presentation/layout/root_shell.dart';
import '../../../../shared/presentation/widgets/ui_badge.dart';

class SchedulePage extends StatelessWidget {
  const SchedulePage({super.key});

  Future<void> _openAddTalkDialog(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Новый доклад'),
        content: const SingleChildScrollView(
          child: SizedBox(
            width: 520,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(decoration: InputDecoration(labelText: 'Секция (id)')),
                SizedBox(height: 8),
                TextField(decoration: InputDecoration(labelText: 'Спикер (id)')),
                SizedBox(height: 8),
                TextField(decoration: InputDecoration(labelText: 'Название доклада')),
                SizedBox(height: 8),
                TextField(
                  maxLines: 3,
                  decoration: InputDecoration(labelText: 'Описание'),
                ),
                SizedBox(height: 8),
                TextField(decoration: InputDecoration(labelText: 'Дата и время')),
                SizedBox(height: 8),
                TextField(decoration: InputDecoration(labelText: 'Длительность (мин)')),
                SizedBox(height: 8),
                TextField(decoration: InputDecoration(labelText: 'Зал')),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Отмена')),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Доклад добавлен в программу (заглушка)')),
              );
            },
            child: const Text('Добавить'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sections = UiMockData.sections;
    final talks = UiMockData.talks;
    final speakers =
        UiMockData.users.where((u) => u.role == UiRole.speaker).toList();

    final grouped = sections
        .map((s) {
          final st = talks.where((t) => t.sectionId == s.id).toList()
            ..sort((a, b) => a.startTime.compareTo(b.startTime));
          return (section: s, talks: st);
        })
        .toList();

    return RootShell(
      role: UiRole.organizer,
      title: 'Наполнение программы',
      child: Column(
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
                onPressed: () => _openAddTalkDialog(context),
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
                        _TalkRow(talk: talk, speakers: speakers),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }
}

class _TalkRow extends StatelessWidget {
  final UiTalk talk;
  final List<UiUser> speakers;

  const _TalkRow({required this.talk, required this.speakers});

  @override
  Widget build(BuildContext context) {
    final sp = speakers.where((u) => u.id == talk.speakerId).firstOrNull;
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
              UiBadge(
                talk.status == UiTalkStatus.ready ? 'Готов' : 'Черновик',
                variant: talk.status == UiTalkStatus.ready
                    ? UiBadgeVariant.defaultFill
                    : UiBadgeVariant.secondary,
              ),
            ],
          ),
          if (talk.description.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              talk.description,
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
              if (sp != null)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.person_outline, size: 16, color: Theme.of(context).hintColor),
                    const SizedBox(width: 4),
                    Text(sp.name, style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.schedule, size: 16, color: Theme.of(context).hintColor),
                  const SizedBox(width: 4),
                  Text(
                    '${_formatDate(talk.startTime)}, ${_formatTime(talk.startTime)} (${talk.durationMin} мин)',
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

extension _FirstOrNull<E> on Iterable<E> {
  E? get firstOrNull {
    final it = iterator;
    return it.moveNext() ? it.current : null;
  }
}
