import 'package:flutter/material.dart';

import '../../../../../app/routes.dart';
import '../../../../shared/mock/ui_mock_data.dart';
import '../../../../shared/mock/ui_models.dart';
import '../../../../shared/presentation/layout/root_shell.dart';
import '../../../../shared/presentation/widgets/ui_badge.dart';

class SpeakerTalksPage extends StatefulWidget {
  final UiRole role;

  const SpeakerTalksPage({super.key, required this.role});

  @override
  State<SpeakerTalksPage> createState() => _SpeakerTalksPageState();
}

class _SpeakerTalksPageState extends State<SpeakerTalksPage> {
  Future<void> _openTalkDialog({UiTalk? editing}) async {
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(editing == null ? 'Новый доклад' : 'Редактировать доклад'),
        content: const SingleChildScrollView(
          child: SizedBox(
            width: 520,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(decoration: InputDecoration(labelText: 'Секция (id)')),
                SizedBox(height: 8),
                TextField(decoration: InputDecoration(labelText: 'Название доклада')),
                SizedBox(height: 8),
                TextField(
                  maxLines: 4,
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
                SnackBar(
                  content: Text(
                    editing == null
                        ? 'Доклад создан (заглушка)'
                        : 'Доклад обновлен (заглушка)',
                  ),
                ),
              );
            },
            child: Text(editing == null ? 'Создать' : 'Сохранить'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = UiMockData.userForRole(widget.role);
    final myTalks =
        UiMockData.talks.where((t) => t.speakerId == user.id).toList();
    final myTasks =
        UiMockData.tasks.where((t) => t.assignedTo == user.id).toList();

    return RootShell(
      role: widget.role,
      title: 'Мои доклады',
      child: Column(
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
                onPressed: () => _openTalkDialog(),
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
                            Icon(
                              task.completed ? Icons.check_box : Icons.check_box_outline_blank,
                              size: 18,
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
                                          decoration: task.completed
                                              ? TextDecoration.lineThrough
                                              : null,
                                          color: task.completed
                                              ? Theme.of(context)
                                                  .colorScheme
                                                  .onSurface
                                                  .withValues(alpha: 0.55)
                                              : null,
                                        ),
                                  ),
                                  if (task.description.isNotEmpty)
                                    Text(
                                      task.description,
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
                final cols = c.maxWidth >= 900 ? 2 : 1;
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
                                    talk.status == UiTalkStatus.ready
                                        ? 'Готов'
                                        : 'Черновик',
                                    variant: talk.status == UiTalkStatus.ready
                                        ? UiBadgeVariant.defaultFill
                                        : UiBadgeVariant.secondary,
                                  ),
                                ],
                              ),
                              if (talk.description.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Text(
                                  talk.description,
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
                                _sectionName(talk.sectionId),
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withValues(alpha: 0.6),
                                    ),
                              ),
                              Text(
                                '${_formatDate(talk.startTime)}, ${_formatTime(talk.startTime)} (${talk.durationMin} мин)',
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
                                  if (talk.status != UiTalkStatus.ready)
                                    Expanded(
                                      child: FilledButton.icon(
                                        onPressed: () {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Доклад отмечен как готовый (заглушка)',
                                              ),
                                            ),
                                          );
                                        },
                                        icon: const Icon(Icons.check_circle_outline, size: 18),
                                        label: const Text('Готовность'),
                                      ),
                                    ),
                                  if (talk.status != UiTalkStatus.ready)
                                    const SizedBox(width: 8),
                                  IconButton(
                                    onPressed: () => _openTalkDialog(editing: talk),
                                    icon: const Icon(Icons.edit_outlined),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Доклад удален (заглушка)'),
                                        ),
                                      );
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
      ),
    );
  }
}

String _sectionName(String id) =>
    UiMockData.sections.firstWhere((s) => s.id == id).name;

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
