import 'package:flutter/material.dart';
import 'package:ready_pro/app/layout/app_breakpoints.dart';

import '../../../../shared/mock/ui_mock_data.dart';
import '../../../../shared/mock/ui_models.dart';
import '../../../../shared/presentation/layout/root_shell.dart';
import '../../../../shared/presentation/widgets/ui_badge.dart';

class CuratorReportsPage extends StatelessWidget {
  const CuratorReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = UiMockData.userForRole(UiRole.curator);
    final mySections =
        UiMockData.sections.where((s) => s.curatorId == user.id).toList();

    return RootShell(
      role: UiRole.curator,
      title: 'Отчеты куратора',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Составьте итоговые отчеты по вашим секциям',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.6),
                ),
          ),
          const SizedBox(height: 16),
          if (mySections.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Center(
                  child: Text(
                    'У вас нет назначенных секций',
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
            for (final section in mySections) ...[
              _SectionReportCard(sectionId: section.id),
              const SizedBox(height: 16),
            ],
        ],
      ),
    );
  }
}

class _SectionReportCard extends StatelessWidget {
  final String sectionId;
  const _SectionReportCard({required this.sectionId});

  @override
  Widget build(BuildContext context) {
    final user = UiMockData.userForRole(UiRole.curator);
    final section = UiMockData.sections.firstWhere((s) => s.id == sectionId);
    final sectionTalks =
        UiMockData.talks.where((t) => t.sectionId == sectionId).toList();
    final sectionComments = UiMockData.comments
        .where((c) => sectionTalks.any((t) => t.id == c.talkId))
        .toList();
    final existingReport = UiMockData.reports
        .where((r) => r.sectionId == sectionId && r.curatorId == user.id)
        .cast<dynamic>()
        .toList()
        .firstOrNull;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.description_outlined, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    section.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            LayoutBuilder(
              builder: (context, c) {
                return GridView.count(
                  crossAxisCount:
                      AppBreakpoints.miniStatColumns(c.maxWidth),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _MiniStat(label: 'Докладов', value: '${sectionTalks.length}'),
                    _MiniStat(
                      label: 'Вопросов/Комментариев',
                      value: '${sectionComments.length}',
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 14),
            Text(
              'Доклады секции',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            for (final talk in sectionTalks)
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Theme.of(context).dividerColor),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            talk.title,
                            style:
                                Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${_formatDate(talk.startTime)} • ${_formatTime(talk.startTime)}',
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
                    UiBadge(
                      talk.status == UiTalkStatus.ready ? 'Готов' : 'Черновик',
                      variant: talk.status == UiTalkStatus.ready
                          ? UiBadgeVariant.defaultFill
                          : UiBadgeVariant.secondary,
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 8),
            Text(
              'Итоговый отчет',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            TextField(
              maxLines: 6,
              decoration: InputDecoration(
                hintText:
                    'Опишите как прошла секция, какие были вопросы, что можно улучшить...',
                helperText: existingReport != null
                    ? 'Есть сохраненный отчет (заглушка, без сохранения)'
                    : null,
              ),
            ),
            const SizedBox(height: 10),
            FilledButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      existingReport != null
                          ? 'Отчет обновлен (заглушка)'
                          : 'Отчет сохранен (заглушка)',
                    ),
                  ),
                );
              },
              child: Text(existingReport != null ? 'Обновить отчет' : 'Сохранить отчет'),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  const _MiniStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: muted)),
          const SizedBox(height: 6),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
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
    'января',
    'февраля',
    'марта',
    'апреля',
    'мая',
    'июня',
    'июля',
    'августа',
    'сентября',
    'октября',
    'ноября',
    'декабря',
  ];
  return '${d.day} ${months[d.month - 1]} ${d.year}';
}

extension<T> on List<T> {
  T? get firstOrNull => isEmpty ? null : first;
}


