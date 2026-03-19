import 'package:flutter/material.dart';

import '../../../../shared/mock/ui_mock_data.dart';
import '../../../../shared/mock/ui_models.dart';
import '../../../../shared/presentation/layout/root_shell.dart';

class TasksPage extends StatefulWidget {
  const TasksPage({super.key});

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  /// Локальное переопределение completed (UI-only).
  final Map<String, bool> _completedOverride = {};

  bool _isDone(UiTask t) => _completedOverride[t.id] ?? t.completed;

  void _toggle(UiTask t) {
    setState(() {
      final cur = _isDone(t);
      _completedOverride[t.id] = !cur;
    });
  }

  Future<void> _openCreateDialog() async {
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Создать задачу'),
        content: const SizedBox(
          width: 480,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(decoration: InputDecoration(labelText: 'Назначить (id)')),
              SizedBox(height: 10),
              TextField(decoration: InputDecoration(labelText: 'Название задачи')),
              SizedBox(height: 10),
              TextField(
                maxLines: 3,
                decoration: InputDecoration(labelText: 'Описание'),
              ),
              SizedBox(height: 10),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Срок выполнения',
                  hintText: 'ГГГГ-ММ-ДД',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Отмена')),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Задача создана (заглушка)')),
              );
            },
            child: const Text('Создать'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tasks = UiMockData.tasks;
    final assignable = UiMockData.users
        .where((u) => u.role == UiRole.curator || u.role == UiRole.speaker)
        .toList();

    final active = tasks.where((t) => !_isDone(t)).toList();
    final done = tasks.where((t) => _isDone(t)).toList();

    return RootShell(
      role: UiRole.organizer,
      title: 'Управление задачами',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Создавайте и отслеживайте задачи для команды',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.6),
                      ),
                ),
              ),
              FilledButton.icon(
                onPressed: _openCreateDialog,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Новая задача'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, c) {
              final two = c.maxWidth >= 900;
              return GridView.count(
                crossAxisCount: two ? 2 : 1,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _TaskColumn(
                    title: 'Активные задачи (${active.length})',
                    tasks: active,
                    assignable: assignable,
                    isDone: _isDone,
                    onToggle: _toggle,
                    mutedCompleted: false,
                  ),
                  _TaskColumn(
                    title: 'Выполненные задачи (${done.length})',
                    tasks: done,
                    assignable: assignable,
                    isDone: _isDone,
                    onToggle: _toggle,
                    mutedCompleted: true,
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

class _TaskColumn extends StatelessWidget {
  final String title;
  final List<UiTask> tasks;
  final List<UiUser> assignable;
  final bool Function(UiTask) isDone;
  final void Function(UiTask) onToggle;
  final bool mutedCompleted;

  const _TaskColumn({
    required this.title,
    required this.tasks,
    required this.assignable,
    required this.isDone,
    required this.onToggle,
    required this.mutedCompleted,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 12),
            if (tasks.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text(
                    title.contains('Активн') ? 'Нет активных задач' : 'Нет выполненных задач',
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
              for (final task in tasks)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Material(
                    color: mutedCompleted
                        ? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.04)
                        : null,
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {},
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Theme.of(context).dividerColor),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Checkbox(
                              value: isDone(task),
                              onChanged: (_) => onToggle(task),
                            ),
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
                                          fontWeight: FontWeight.w600,
                                          decoration: mutedCompleted
                                              ? TextDecoration.lineThrough
                                              : null,
                                          color: mutedCompleted
                                              ? Theme.of(context)
                                                  .colorScheme
                                                  .onSurface
                                                  .withValues(alpha: 0.55)
                                              : null,
                                        ),
                                  ),
                                  if (task.description.isNotEmpty) ...[
                                    const SizedBox(height: 4),
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
                                  const SizedBox(height: 6),
                                  Text(
                                    _assigneeName(task, assignable),
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface
                                              .withValues(alpha: 0.5),
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}

String _assigneeName(UiTask task, List<UiUser> assignable) {
  final u = assignable.where((x) => x.id == task.assignedTo).firstOrNull;
  if (u == null) return 'Исполнитель: —';
  final role = u.role == UiRole.curator ? 'Куратор' : 'Спикер';
  return '$role: ${u.name}';
}

extension _FirstOrNull<E> on Iterable<E> {
  E? get firstOrNull {
    final it = iterator;
    return it.moveNext() ? it.current : null;
  }
}
