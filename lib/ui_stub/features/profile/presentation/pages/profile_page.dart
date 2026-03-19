import 'package:flutter/material.dart';

import '../../../../../app/routes.dart';
import '../../../../../app/widgets/theme_toggle_button.dart';
import '../../../../shared/mock/ui_mock_data.dart';
import '../../../../shared/mock/ui_models.dart';
import '../../../../shared/presentation/layout/root_shell.dart';
import '../../../../shared/presentation/widgets/ui_badge.dart';

class ProfilePage extends StatelessWidget {
  final UiRole role;

  const ProfilePage({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    final user = UiMockData.userForRole(role);
    final myTasks =
        UiMockData.tasks.where((t) => t.assignedTo == user.id).toList();
    final myTalks =
        UiMockData.talks.where((t) => t.speakerId == user.id).toList();
    final mySections =
        UiMockData.sections.where((s) => s.curatorId == user.id).toList();

    return RootShell(
      role: role,
      title: 'Профиль',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  'Ваша информация и активность',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.6),
                      ),
                ),
              ),
              const ThemeToggleButton(),
            ],
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.account_circle_outlined, size: 22),
                      const SizedBox(width: 8),
                      Text(
                        'Основная информация',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                  const Divider(height: 28),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 36,
                        backgroundColor:
                            Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
                        child: Icon(
                          Icons.person,
                          size: 36,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.name,
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Icon(Icons.mail_outline, size: 16, color: Theme.of(context).hintColor),
                                const SizedBox(width: 6),
                                Expanded(child: Text(user.email)),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Icon(Icons.work_outline, size: 16, color: Theme.of(context).hintColor),
                                const SizedBox(width: 6),
                                UiBadge(_roleLabelRu(role), variant: UiBadgeVariant.secondary),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 28),
                  LayoutBuilder(
                    builder: (context, c) {
                      final n = 1 +
                          (role == UiRole.speaker ? 1 : 0) +
                          (role == UiRole.curator ? 1 : 0);
                      final cols = c.maxWidth >= 520 ? n : 1;
                      return GridView.count(
                        crossAxisCount: cols,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.6,
                        children: [
                          _StatTile(value: '${myTasks.length}', label: 'Задач'),
                          if (role == UiRole.speaker)
                            _StatTile(value: '${myTalks.length}', label: 'Докладов'),
                          if (role == UiRole.curator)
                            _StatTile(value: '${mySections.length}', label: 'Секций'),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          if (myTasks.isNotEmpty) ...[
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.checklist_outlined, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Мои задачи',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    for (final task in myTasks)
                      Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Theme.of(context).dividerColor),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              task.completed ? Icons.check_box : Icons.check_box_outline_blank,
                              size: 18,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    task.title,
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          fontWeight: FontWeight.w600,
                                          decoration: task.completed
                                              ? TextDecoration.lineThrough
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
                                                .withValues(alpha: 0.65),
                                          ),
                                    ),
                                ],
                              ),
                            ),
                            UiBadge(
                              task.completed ? 'Выполнено' : 'В работе',
                              variant: task.completed
                                  ? UiBadgeVariant.defaultFill
                                  : UiBadgeVariant.secondary,
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
          if (role == UiRole.speaker && myTalks.isNotEmpty) ...[
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Мои доклады',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 10),
                    for (final talk in myTalks)
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(talk.title),
                        subtitle: Text(
                          '${_sectionName(talk.sectionId)} • ${_formatShort(talk.startTime)}',
                        ),
                        trailing: UiBadge(
                          talk.status == UiTalkStatus.ready ? 'Готов' : 'Черновик',
                          variant: talk.status == UiTalkStatus.ready
                              ? UiBadgeVariant.defaultFill
                              : UiBadgeVariant.secondary,
                        ),
                        onTap: () => Navigator.pushNamed(
                          context,
                          AppRoutes.talkDetails,
                          arguments: {'role': role, 'talkId': talk.id},
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
          if (role == UiRole.curator && mySections.isNotEmpty) ...[
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Мои секции',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 10),
                    for (final section in mySections)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(section.name),
                          subtitle: Text(
                            '${section.room ?? 'Зал не указан'} • '
                            '${UiMockData.talks.where((t) => t.sectionId == section.id).length} докладов',
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 20),
          OutlinedButton.icon(
            onPressed: () => Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.login,
              (_) => false,
            ),
            icon: const Icon(Icons.logout),
            label: const Text('Выйти'),
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String value;
  final String label;

  const _StatTile({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.6),
                ),
          ),
        ],
      ),
    );
  }
}

String _roleLabelRu(UiRole r) {
  switch (r) {
    case UiRole.organizer:
      return 'Организатор';
    case UiRole.curator:
      return 'Куратор';
    case UiRole.speaker:
      return 'Спикер';
    case UiRole.participant:
      return 'Участник';
  }
}

String _sectionName(String id) =>
    UiMockData.sections.firstWhere((s) => s.id == id).name;

String _formatShort(DateTime d) {
  const m = [
    'янв', 'фев', 'мар', 'апр', 'май', 'июн',
    'июл', 'авг', 'сен', 'окт', 'ноя', 'дек',
  ];
  return '${d.day} ${m[d.month - 1]} ${d.year}';
}
