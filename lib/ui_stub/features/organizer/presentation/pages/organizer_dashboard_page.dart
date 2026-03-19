import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ready_pro/blocs/event/event_bloc.dart';
import 'package:ready_pro/blocs/event/event_event.dart';
import 'package:ready_pro/blocs/organizer/organizer_bloc.dart';
import 'package:ready_pro/blocs/organizer/organizer_event.dart';
import 'package:ready_pro/blocs/organizer/organizer_state.dart';
import 'package:ready_pro/core/enums.dart';

import '../../../../../app/routes.dart';
import '../../../../shared/presentation/layout/root_shell.dart';
import '../../../../shared/presentation/widgets/stat_card.dart';
import '../../../../shared/presentation/widgets/ui_progress.dart';
import '../../../../shared/mock/ui_models.dart';
import '../../../../shared/route_args.dart';

class OrganizerDashboardPage extends StatefulWidget {
  const OrganizerDashboardPage({super.key});

  @override
  State<OrganizerDashboardPage> createState() => _OrganizerDashboardPageState();
}

class _OrganizerDashboardPageState extends State<OrganizerDashboardPage> {
  String? _eventId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final newEventId = eventIdFromArgs(ModalRoute.of(context)?.settings.arguments);
    if (newEventId != null && newEventId.isNotEmpty && _eventId != newEventId) {
      _eventId = newEventId;
      context.read<OrganizerBloc>().add(FetchOrganizerDashboard(_eventId!));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_eventId == null || _eventId!.isEmpty) {
      return RootShell(
        role: UiRole.organizer,
        title: 'Дашборд организатора',
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.orange),
              const SizedBox(height: 16),
              const Text('Мероприятие не выбрано или ID невалиден'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pushReplacementNamed(context, AppRoutes.profile, arguments: {'role': UiRole.organizer}),
                child: const Text('Вернуться в профиль'),
              ),
            ],
          ),
        ),
      );
    }

    return RootShell(
      role: UiRole.organizer,
      title: 'Дашборд организатора',
      child: BlocBuilder<OrganizerBloc, OrganizerState>(
        builder: (context, state) {
          if (state is OrganizerLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is OrganizerError) {
            return Center(child: Text('Ошибка: ${state.message}'));
          }

          if (state is OrganizerDashboardLoaded) {
            final event = state.event;
            final sections = state.sections;
            final tasks = state.tasks;
            final talks = state.talks;

            final completedTasks = tasks.where((t) => t.isCompleted).length;
            final totalTasks = tasks.length;
            final progressPercentage =
                totalTasks == 0 ? 0.0 : (completedTasks / totalTasks) * 100.0;

            final readyTalks = talks.where((t) => t.status == TalkStatus.ready).length;
            final totalTalks = talks.length;

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
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
                        childAspectRatio: 1.5,
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
                                '${tasks.where((t) => !t.isCompleted).length} активных',
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
                        childAspectRatio: 1.2,
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
                                  for (final task in tasks.take(3))
                                    Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 6),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(top: 2),
                                            child: Icon(
                                              task.isCompleted
                                                  ? Icons.check_box
                                                  : Icons.check_box_outline_blank,
                                              size: 18,
                                              color: task.isCompleted
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
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyMedium
                                                      ?.copyWith(
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
                                  const Spacer(),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: TextButton(
                                      onPressed: () => Navigator.pushNamed(
                                        context,
                                        AppRoutes.organizerTasks,
                                        arguments: {'role': UiRole.organizer, 'eventId': _eventId},
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
                                  for (final section in sections.take(3))
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
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyMedium
                                                      ?.copyWith(
                                                        fontWeight: FontWeight.w600,
                                                      ),
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  'Прогресс: ${section.progress}%${section.curatorId != null ? ' • Куратор назначен' : ''}',
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
                                  const Spacer(),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: TextButton(
                                      onPressed: () => Navigator.pushNamed(
                                        context,
                                        AppRoutes.organizerSections,
                                        arguments: {'role': UiRole.organizer, 'eventId': _eventId},
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
                        onPressed: () => Navigator.pushNamed(
                          context,
                          AppRoutes.organizerSchedule,
                          arguments: {'role': UiRole.organizer, 'eventId': _eventId},
                        ),
                        icon: const Icon(Icons.calendar_month_outlined),
                        label: const Text('Наполнение программы'),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => _showInviteDialog(context),
                        icon: const Icon(Icons.person_add_alt_1_outlined),
                        label: const Text('Назначить на должность'),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }

          return const Center(child: Text('Нет данных'));
        },
      ),
    );
  }

  void _showInviteDialog(BuildContext context) {
    if (_eventId == null) return;
    final emailController = TextEditingController();
    UserRole selectedRole = UserRole.curator;
    final roles = [UserRole.curator, UserRole.speaker];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Назначить на должность'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email пользователя',
                hintText: 'example@mail.com',
                prefixIcon: Icon(Icons.email_outlined),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<UserRole>(
              value: selectedRole,
              items: roles.map((r) => DropdownMenuItem(
                value: r,
                child: Text(_userRoleLabelRu(r)),
              )).toList(),
              onChanged: (val) {
                if (val != null) selectedRole = val;
              },
              decoration: const InputDecoration(labelText: 'Выберите должность'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Отмена')),
          ElevatedButton(
            onPressed: () {
              if (emailController.text.isNotEmpty) {
                context.read<EventBloc>().add(AssignRoleRequested(
                  eventId: _eventId!,
                  email: emailController.text.trim(),
                  role: selectedRole,
                ));
                Navigator.pop(context);
              }
            },
            child: const Text('Назначить'),
          ),
        ],
      ),
    );
  }
}

String _userRoleLabelRu(UserRole r) {
  switch (r) {
    case UserRole.organizer: return 'Организатор';
    case UserRole.curator: return 'Куратор';
    case UserRole.speaker: return 'Спикер';
    case UserRole.participant: return 'Участник';
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
