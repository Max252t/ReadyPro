import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ready_pro/blocs/auth/auth_bloc.dart';
import 'package:ready_pro/blocs/auth/auth_state.dart';
import 'package:ready_pro/blocs/organizer/organizer_bloc.dart';
import 'package:ready_pro/blocs/organizer/organizer_event.dart';
import 'package:ready_pro/blocs/organizer/organizer_state.dart';
import 'package:ready_pro/blocs/event/event_bloc.dart';
import 'package:ready_pro/blocs/event/event_event.dart';
import 'package:ready_pro/blocs/event/event_state.dart';
import 'package:ready_pro/models/task.dart';
import 'package:ready_pro/models/user.dart';
import 'package:ready_pro/app/layout/app_breakpoints.dart';

import '../../../../shared/presentation/layout/root_shell.dart';
import '../../../../shared/mock/ui_models.dart';
import '../../../../shared/route_args.dart';

class TasksPage extends StatefulWidget {
  const TasksPage({super.key});

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  String? _eventId;
  List<Profile> _allParticipants = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final newEventId = eventIdFromArgs(ModalRoute.of(context)?.settings.arguments);
    if (newEventId != null && newEventId.isNotEmpty && _eventId != newEventId) {
      _eventId = newEventId;
      _refreshData();
    }
  }

  void _refreshData() {
    if (_eventId == null) return;
    context.read<OrganizerBloc>().add(FetchOrganizerDashboard(_eventId!));
    context.read<EventBloc>().add(LoadEventParticipants(_eventId!));
  }

  Future<void> _openCreateDialog(BuildContext context, String eventId) async {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    Profile? selectedAssignee;
    final dueDateController = TextEditingController(
      text: DateTime.now().add(const Duration(days: 7)).toIso8601String().split('T')[0],
    );

    // Фильтруем участников: только кураторы и спикеры
    // (Хотя в некоторых случаях можно назначать и участникам, но по запросу - кураторы и спикеры)
    // Мы можем сделать это прямо в диалоге или заранее.
    
    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) {
          final candidates = _allParticipants;

          return AlertDialog(
            title: const Text('Создать задачу'),
            content: SizedBox(
              width: 480,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<Profile>(
                      isExpanded: true,
                      decoration: const InputDecoration(labelText: 'Исполнитель (Поиск по имени)'),
                      items: candidates.map((p) => DropdownMenuItem(
                        value: p,
                        child: Text('${p.fullName} (${p.email})'),
                      )).toList(),
                      onChanged: (val) => setState(() => selectedAssignee = val),
                      value: selectedAssignee,
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(labelText: 'Название задачи'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: descController,
                      maxLines: 3,
                      decoration: const InputDecoration(labelText: 'Описание'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: dueDateController,
                      decoration: const InputDecoration(
                        labelText: 'Срок выполнения',
                        hintText: 'ГГГГ-ММ-ДД',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Отмена')),
              FilledButton(
                onPressed: () {
                  if (selectedAssignee == null) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Выберите исполнителя')));
                    return;
                  }
                  
                  final authState = context.read<AuthBloc>().state;
                  String currentUserId = '';
                  if (authState is AuthAuthenticated) {
                    currentUserId = authState.user.id;
                  }

                  final task = Task(
                    id: '', 
                    eventId: eventId,
                    assigneeId: selectedAssignee!.id,
                    assignerId: currentUserId,
                    title: titleController.text,
                    description: descController.text,
                    dueDate: DateTime.tryParse(dueDateController.text) ?? DateTime.now().add(const Duration(days: 7)),
                    isCompleted: false,
                  );
                  context.read<OrganizerBloc>().add(CreateTask(task));
                  Navigator.pop(ctx);
                },
                child: const Text('Создать'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_eventId == null) {
      return const RootShell(
        role: UiRole.organizer,
        title: 'Управление задачами',
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return MultiBlocListener(
      listeners: [
        BlocListener<EventBloc, EventState>(
          listener: (context, state) {
            if (state is EventParticipantsLoaded) {
              setState(() {
                _allParticipants = state.participants;
              });
            }
          },
        ),
      ],
      child: RootShell(
        role: UiRole.organizer,
        title: 'Управление задачами',
        child: BlocBuilder<OrganizerBloc, OrganizerState>(
          builder: (context, state) {
            if (state is OrganizerLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is OrganizerDashboardLoaded) {
              final tasks = state.tasks;
              final eventId = state.event.id;

              final active = tasks.where((t) => !t.isCompleted).toList();
              final done = tasks.where((t) => t.isCompleted).toList();

              return Column(
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
                        onPressed: () => _openCreateDialog(context, eventId),
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Новая задача'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, c) {
                        return GridView.count(
                          crossAxisCount:
                              AppBreakpoints.taskBoardColumns(c.maxWidth),
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          children: [
                            _TaskColumn(
                              title: 'Активные задачи (${active.length})',
                              tasks: active,
                              allParticipants: _allParticipants,
                              onToggle: (task) {
                                final updatedTask = Task(
                                  id: task.id,
                                  eventId: task.eventId,
                                  assigneeId: task.assigneeId,
                                  assignerId: task.assignerId,
                                  title: task.title,
                                  description: task.description,
                                  dueDate: task.dueDate,
                                  isCompleted: !task.isCompleted,
                                );
                                context.read<OrganizerBloc>().add(UpdateTask(updatedTask));
                              },
                              mutedCompleted: false,
                            ),
                            _TaskColumn(
                              title: 'Выполненные задачи (${done.length})',
                              tasks: done,
                              allParticipants: _allParticipants,
                              onToggle: (task) {
                                final updatedTask = Task(
                                  id: task.id,
                                  eventId: task.eventId,
                                  assigneeId: task.assigneeId,
                                  assignerId: task.assignerId,
                                  title: task.title,
                                  description: task.description,
                                  dueDate: task.dueDate,
                                  isCompleted: !task.isCompleted,
                                );
                                context.read<OrganizerBloc>().add(UpdateTask(updatedTask));
                              },
                              mutedCompleted: true,
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              );
            }
            return const Center(child: Text('Нет данных'));
          },
        ),
      ),
    );
  }
}

class _TaskColumn extends StatelessWidget {
  final String title;
  final List<Task> tasks;
  final List<Profile> allParticipants;
  final void Function(Task) onToggle;
  final bool mutedCompleted;

  const _TaskColumn({
    required this.title,
    required this.tasks,
    required this.allParticipants,
    required this.onToggle,
    required this.mutedCompleted,
  });

  String _getAssigneeName(String id) {
    try {
      final p = allParticipants.firstWhere((p) => p.id == id);
      return p.fullName;
    } catch (_) {
      return id;
    }
  }

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
              Expanded(
                child: ListView.builder(
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Material(
                        color: mutedCompleted
                            ? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.04)
                            : null,
                        borderRadius: BorderRadius.circular(12),
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
                                value: task.isCompleted,
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
                                            decoration: task.isCompleted
                                                ? TextDecoration.lineThrough
                                                : null,
                                            color: task.isCompleted
                                                ? Theme.of(context)
                                                    .colorScheme
                                                    .onSurface
                                                    .withValues(alpha: 0.55)
                                                : null,
                                          ),
                                    ),
                                    if (task.description != null && task.description!.isNotEmpty) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        task.description!,
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
                                      'Исполнитель: ${_getAssigneeName(task.assigneeId)}',
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
                              IconButton(
                                icon: const Icon(Icons.delete_outline, size: 20),
                                onPressed: () {
                                  context.read<OrganizerBloc>().add(DeleteTask(task.id, task.eventId));
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
