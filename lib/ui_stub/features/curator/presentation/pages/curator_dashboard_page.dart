import 'package:flutter/material.dart';

import '../../../../../app/routes.dart';
import '../../../../shared/mock/ui_mock_data.dart';
import '../../../../shared/mock/ui_models.dart';
import '../../../../shared/presentation/layout/root_shell.dart';
import '../../../../shared/presentation/widgets/stat_card.dart';
import '../../../../shared/presentation/widgets/ui_badge.dart';

class CuratorDashboardPage extends StatelessWidget {
  const CuratorDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = UiMockData.userForRole(UiRole.curator);
    final sections =
        UiMockData.sections.where((s) => s.curatorId == user.id).toList();
    final talks = UiMockData.talks
        .where((t) => sections.any((s) => s.id == t.sectionId))
        .toList();
    final tasks =
        UiMockData.tasks.where((t) => t.assignedTo == user.id).toList();
    final activeTasks = tasks.where((t) => !t.completed).length;
    final comments = UiMockData.comments
        .where((c) => talks.any((t) => t.id == c.talkId))
        .toList();

    return RootShell(
      role: UiRole.curator,
      title: 'Дашборд куратора',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, c) {
              final columns = c.maxWidth >= 900 ? 3 : 1;
              return GridView.count(
                crossAxisCount: columns,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  StatCard(
                    title: 'Мои секции',
                    value: '${sections.length}',
                    icon: Icons.groups_outlined,
                    subtitle: '${talks.length} докладов',
                  ),
                  StatCard(
                    title: 'Задачи',
                    value: '${tasks.length}',
                    icon: Icons.checklist_outlined,
                    subtitle: '$activeTasks активных',
                  ),
                  StatCard(
                    title: 'Вопросы',
                    value: '${comments.length}',
                    icon: Icons.chat_bubble_outline,
                    subtitle: 'к вашим секциям',
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
                            'Мои задачи',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 12),
                          if (tasks.isEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 24),
                              child: Text(
                                'Нет назначенных задач',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withValues(alpha: 0.6),
                                    ),
                              ),
                            )
                          else
                            for (final task in tasks)
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 6),
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
                                            ? Theme.of(context)
                                                .colorScheme
                                                .primary
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
                                                  fontWeight: FontWeight.w600,
                                                  decoration: task.completed
                                                      ? TextDecoration
                                                          .lineThrough
                                                      : null,
                                                ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            task.description,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall
                                                ?.copyWith(
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
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Доклады моих секций',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 12),
                          if (talks.isEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 24),
                              child: Text(
                                'Доклады не добавлены',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withValues(alpha: 0.6),
                                    ),
                              ),
                            )
                          else
                            for (final talk in talks)
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 4,
                                      height: 34,
                                      decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  talk.title,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyMedium
                                                      ?.copyWith(
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              UiBadge(
                                                talk.status ==
                                                        UiTalkStatus.ready
                                                    ? 'Готов'
                                                    : 'Черновик',
                                                variant: talk.status ==
                                                        UiTalkStatus.ready
                                                    ? UiBadgeVariant.defaultFill
                                                    : UiBadgeVariant.secondary,
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            '${_sectionName(talk.sectionId)} • ${_formatTime(talk.startTime)}',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall
                                                ?.copyWith(
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
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: OutlinedButton.icon(
                              onPressed: () => Navigator.pushReplacementNamed(
                                context,
                                AppRoutes.curatorReports,
                              ),
                              icon: const Icon(Icons.description_outlined),
                              label: const Text('Перейти к отчётам'),
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
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => Navigator.pushNamed(
              context,
              AppRoutes.talkDetails,
              arguments: const {'talkId': 'talk1'},
            ),
            icon: const Icon(Icons.open_in_new),
            label: const Text('Открыть доклад (пример)'),
          ),
        ],
      ),
    );
  }
}

String _sectionName(String sectionId) {
  final s = UiMockData.sections.firstWhere((x) => x.id == sectionId);
  return s.name;
}

String _formatTime(DateTime d) {
  final hh = d.hour.toString().padLeft(2, '0');
  final mm = d.minute.toString().padLeft(2, '0');
  return '$hh:$mm';
}

