import 'package:flutter/material.dart';

import '../../../../shared/mock/ui_mock_data.dart';
import '../../../../shared/mock/ui_models.dart';
import '../../../../shared/presentation/layout/root_shell.dart';
import '../../../../shared/presentation/widgets/ui_badge.dart';

class SectionsPage extends StatelessWidget {
  const SectionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final sections = UiMockData.sections;
    final curators = UiMockData.users.where((u) => u.role == UiRole.curator);

    return RootShell(
      role: UiRole.organizer,
      title: 'Управление секциями',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Создавайте и редактируйте секции мероприятия',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.6),
                      ),
                ),
              ),
              FilledButton.icon(
                onPressed: () => _openSectionDialog(context),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Добавить секцию'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, c) {
              final cols = c.maxWidth >= 1100 ? 3 : (c.maxWidth >= 750 ? 2 : 1);
              return GridView.count(
                crossAxisCount: cols,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  for (final section in sections)
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
                                    section.name,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(fontWeight: FontWeight.w600),
                                  ),
                                ),
                                IconButton(
                                  onPressed: () => _openSectionDialog(
                                    context,
                                    section: section,
                                  ),
                                  icon: const Icon(Icons.edit_outlined),
                                  tooltip: 'Редактировать',
                                ),
                                IconButton(
                                  onPressed: () => _confirmStub(
                                    context,
                                    'Секция удалена (заглушка)',
                                  ),
                                  icon: const Icon(Icons.delete_outline),
                                  tooltip: 'Удалить',
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              section.description,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.6),
                                  ),
                            ),
                            const SizedBox(height: 12),
                            if (section.room != null)
                              Text(
                                'Зал: ${section.room}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            const SizedBox(height: 10),
                            if (section.curatorId != null)
                              Row(
                                children: [
                                  const Icon(Icons.groups_outlined, size: 16),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      curators
                                          .firstWhere(
                                            (c) => c.id == section.curatorId,
                                            orElse: () => const UiUser(
                                              id: 'x',
                                              email: '',
                                              name: 'Куратор',
                                              role: UiRole.curator,
                                            ),
                                          )
                                          .name,
                                      style: Theme.of(context).textTheme.bodySmall,
                                    ),
                                  ),
                                  const UiBadge(
                                    'Куратор',
                                    variant: UiBadgeVariant.secondary,
                                  ),
                                ],
                              )
                            else
                              Text(
                                'Куратор не назначен',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withValues(alpha: 0.55),
                                      fontStyle: FontStyle.italic,
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
        ],
      ),
    );
  }
}

Future<void> _openSectionDialog(
  BuildContext context, {
  UiSection? section,
}) async {
  await showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(section == null ? 'Новая секция' : 'Редактировать секцию'),
      content: const SizedBox(
        width: 560,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(decoration: InputDecoration(labelText: 'Название')),
            SizedBox(height: 10),
            TextField(
              maxLines: 3,
              decoration: InputDecoration(labelText: 'Описание'),
            ),
            SizedBox(height: 10),
            TextField(decoration: InputDecoration(labelText: 'Куратор (id)')),
            SizedBox(height: 10),
            TextField(decoration: InputDecoration(labelText: 'Зал')),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: Navigator.of(context).pop, child: const Text('Отмена')),
        FilledButton(
          onPressed: () {
            Navigator.of(context).pop();
            _confirmStub(
              context,
              section == null ? 'Секция создана (заглушка)' : 'Секция обновлена (заглушка)',
            );
          },
          child: Text(section == null ? 'Создать' : 'Сохранить'),
        ),
      ],
    ),
  );
}

void _confirmStub(BuildContext context, String text) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
}

