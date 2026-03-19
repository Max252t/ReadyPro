import 'package:flutter/material.dart';

import '../../../../../app/routes.dart';
import '../../../../shared/mock/ui_mock_data.dart';
import '../../../../shared/presentation/layout/root_shell.dart';
import '../../../../shared/presentation/widgets/stat_card.dart';
import '../../../../shared/presentation/widgets/ui_progress.dart';
import '../../../../shared/presentation/widgets/ui_badge.dart';
import '../../../../shared/mock/ui_models.dart';

class OrganizerDashboardPage extends StatelessWidget {
  const OrganizerDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final event = UiMockData.events.first;
    final sections = UiMockData.sections;
    final tasks = UiMockData.tasks;
    final talks = UiMockData.talks;

    final completedTasks = tasks.where((t) => t.completed).length;
    final totalTasks = tasks.length;
    final progressPercentage =
        totalTasks == 0 ? 0.0 : (completedTasks / totalTasks) * 100.0;

    final readyTalks = talks.where((t) => t.status == UiTalkStatus.ready).length;
    final totalTalks = talks.length;

    return RootShell(
      role: UiRole.organizer,
      title: 'Дашборд организатора',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            event.name,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.6),
                ),
          ),
          const SizedBox(height: 18),
          LayoutBuilder(
            builder: (context, c) {
              final isWide = c.maxWidth >= 1100;
              final isMid = c.maxWidth >= 700;
              final columns = isWide ? 4 : (isMid ? 2 : 1);

              return GridView.count(
                crossAxisCount: columns,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  StatCard(
                    title: 'Общий прогресс',
                    value: '${progressPercentage.round()}%',
                    icon: Icons.trending_up,
                    footer: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        UiProgress(value: progressPercentage),
                        const SizedBox(height: 8),
                        Text(
                          '$completedTasks из $totalTasks задач выполнено',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.55),
                                  ),
                        ),
                      ],
                    ),
                  ),
                  StatCard(
                    title: 'Секции',
                    value: '${sections.length}',
                    icon: Icons.groups_outlined,
                    subtitle:
                        '${sections.where((s) => s.curatorId != null).length} с кураторами',
                  ),
                  StatCard(
                    title: 'Задачи',
                    value: '$totalTasks',
                    icon: Icons.checklist_outlined,
                    subtitle:
                        '${tasks.where((t) => !t.completed).length} активных',
                  ),
                  StatCard(
                    title: 'Доклады',
                    value: '$totalTalks',
                    icon: Icons.calendar_month_outlined,
                    subtitle: '$readyTalks готовы',
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, c) {
              final twoCols = c.maxWidth >= 900;
              return GridView.count(
                crossAxisCount: twoCols ? 2 : 1,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Последние задачи',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 12),
                          for (final task in tasks.take(5))
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(top: 2),
                                    child: Icon(
                                      task.completed
                                          ? Icons.check_box
                                          : Icons.check_box_outline_blank,
                                      size: 18,
                                      color: task.completed
                                          ? Theme.of(context).colorScheme.primary
                                          : Theme.of(context)
                                              .colorScheme
                                              .onSurface
                                              .withValues(alpha: 0.45),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                        const SizedBox(height: 2),
                                        Text(
                                          'Срок: ${_formatDate(task.dueDate)}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onSurface
                                                    .withValues(alpha: 0.55),
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: TextButton(
                              onPressed: () => Navigator.pushReplacementNamed(
                                context,
                                AppRoutes.organizerTasks,
                              ),
                              child: const Text('Открыть задачи'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Секции мероприятия',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 12),
                          for (final section in sections)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 4,
                                    height: 34,
                                    decoration: BoxDecoration(
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          section.name,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '${section.room ?? 'Зал не указан'}${section.curatorId != null ? ' • Куратор назначен' : ''}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onSurface
                                                    .withValues(alpha: 0.55),
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: TextButton(
                              onPressed: () => Navigator.pushReplacementNamed(
                                context,
                                AppRoutes.organizerSections,
                              ),
                              child: const Text('Управлять секциями'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              OutlinedButton.icon(
                onPressed: () => Navigator.pushReplacementNamed(
                  context,
                  AppRoutes.organizerSchedule,
                ),
                icon: const Icon(Icons.calendar_month_outlined),
                label: const Text('Наполнение программы'),
              ),
              OutlinedButton.icon(
                onPressed: () => Navigator.pushNamed(
                  context,
                  AppRoutes.talkDetails,
                  arguments: const {'talkId': 'talk1'},
                ),
                icon: const Icon(Icons.open_in_new),
                label: const Text('Открыть доклад (пример)'),
              ),
              UiBadge(
                'UI-only',
                variant: UiBadgeVariant.secondary,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

String _formatDate(DateTime d) {
  const months = [
    'янв',
    'фев',
    'мар',
    'апр',
    'май',
    'июн',
    'июл',
    'авг',
    'сен',
    'окт',
    'ноя',
    'дек',
  ];
  return '${d.day} ${months[d.month - 1]} ${d.year}';
}

