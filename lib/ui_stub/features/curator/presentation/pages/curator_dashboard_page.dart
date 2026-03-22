import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ready_pro/blocs/auth/auth_bloc.dart';
import 'package:ready_pro/blocs/auth/auth_state.dart';
import 'package:ready_pro/blocs/curator/curator_bloc.dart';
import 'package:ready_pro/blocs/curator/curator_event.dart';
import 'package:ready_pro/blocs/curator/curator_state.dart';
import 'package:ready_pro/blocs/organizer/organizer_bloc.dart';
import 'package:ready_pro/blocs/organizer/organizer_event.dart';
import 'package:ready_pro/blocs/organizer/organizer_state.dart';
import 'package:ready_pro/blocs/event/event_bloc.dart';
import 'package:ready_pro/blocs/event/event_event.dart';
import 'package:ready_pro/blocs/event/event_state.dart';
import 'package:ready_pro/app/layout/app_breakpoints.dart';
import 'package:ready_pro/core/enums.dart';
import 'package:ready_pro/models/user.dart';

import '../../../../../app/routes.dart';
import '../../../../shared/mock/ui_models.dart';
import '../../../../shared/presentation/layout/root_shell.dart';
import '../../../../shared/presentation/widgets/stat_card.dart';
import '../../../../shared/presentation/widgets/ui_badge.dart';
import '../../../../shared/route_args.dart';

class CuratorDashboardPage extends StatefulWidget {
  const CuratorDashboardPage({super.key});

  @override
  State<CuratorDashboardPage> createState() => _CuratorDashboardPageState();
}

class _CuratorDashboardPageState extends State<CuratorDashboardPage> {
  String? _eventId;

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
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<CuratorBloc>().add(FetchCuratorSection(
            userId: authState.user.id,
            eventId: _eventId!,
          ));
      context.read<OrganizerBloc>().add(FetchOrganizerDashboard(_eventId!));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_eventId == null) {
      return const RootShell(
        role: UiRole.curator,
        title: 'Дашборд куратора',
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return RootShell(
      role: UiRole.curator,
      title: 'Дашборд куратора',
      child: BlocBuilder<CuratorBloc, CuratorState>(
        builder: (context, curatorState) {
          return BlocBuilder<OrganizerBloc, OrganizerState>(
            builder: (context, organizerState) {
              if (curatorState is CuratorLoading || organizerState is OrganizerLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (curatorState is CuratorError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.info_outline, size: 64, color: Colors.blueGrey),
                        const SizedBox(height: 16),
                        Text(
                          'У вас пока нет назначенной секции',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Свяжитесь с организатором, чтобы он назначил вас куратором одной из секций мероприятия.',
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        FilledButton.icon(
                          onPressed: _refreshData,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Проверить снова'),
                        ),
                      ],
                    ),
                  ),
                );
              }

              if (curatorState is CuratorSectionLoaded) {
                final section = curatorState.section;
                final talks = curatorState.talks;
                
                final authState = context.read<AuthBloc>().state;
                final userId = authState is AuthAuthenticated ? authState.user.id : '';
                
                final tasks = organizerState is OrganizerDashboardLoaded
                    ? organizerState.tasks.where((t) => t.assigneeId == userId).toList()
                    : [];
                final activeTasksCount = tasks.where((t) => !t.isCompleted).length;

                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      LayoutBuilder(
                        builder: (context, c) {
                          final columns =
                              AppBreakpoints.curatorStatColumns(c.maxWidth);
                          return GridView.count(
                            crossAxisCount: columns,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            children: [
                              StatCard(
                                title: 'Моя секция',
                                value: section.name,
                                icon: Icons.groups_outlined,
                                subtitle: '${talks.length} докладов',
                              ),
                              StatCard(
                                title: 'Задачи',
                                value: '${tasks.length}',
                                icon: Icons.checklist_outlined,
                                subtitle: '$activeTasksCount активных',
                              ),
                              StatCard(
                                title: 'Прогресс секции',
                                value: '${section.progress}%',
                                icon: Icons.trending_up,
                                subtitle: 'текущее состояние',
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      LayoutBuilder(
                        builder: (context, c) {
                          return GridView.count(
                            crossAxisCount:
                                AppBreakpoints.twoColumnCards(c.maxWidth),
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
                                        Expanded(
                                          child: ListView(
                                            shrinkWrap: true,
                                            children: [
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
                                                          task.isCompleted
                                                              ? Icons.check_box
                                                              : Icons.check_box_outline_blank,
                                                          size: 18,
                                                          color: task.isCompleted
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
                                                                    decoration: task.isCompleted
                                                                        ? TextDecoration
                                                                            .lineThrough
                                                                        : null,
                                                                  ),
                                                            ),
                                                            if (task.description != null)
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
                                        'Доклады моей секции',
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
                                        Expanded(
                                          child: ListView(
                                            shrinkWrap: true,
                                            children: [
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
                                                                  talk.status == TalkStatus.ready
                                                                      ? 'Готов'
                                                                      : 'Черновик',
                                                                  variant: talk.status == TalkStatus.ready
                                                                      ? UiBadgeVariant.defaultFill
                                                                      : UiBadgeVariant.secondary,
                                                                ),
                                                              ],
                                                            ),
                                                            const SizedBox(height: 2),
                                                            Text(
                                                              '${section.name} • ${talk.startTime != null ? _formatTime(talk.startTime!) : 'Время не указано'}',
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
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          OutlinedButton.icon(
                                            onPressed: () => Navigator.pushReplacementNamed(
                                              context,
                                              AppRoutes.curatorReports,
                                              arguments: {'role': UiRole.curator, 'eventId': _eventId},
                                            ),
                                            icon: const Icon(Icons.description_outlined),
                                            label: const Text('Отчёты'),
                                          ),
                                          const SizedBox(width: 8),
                                          TextButton.icon(
                                            onPressed: () => _showAssignSpeakerDialog(context),
                                            icon: const Icon(Icons.person_add_alt_1_outlined),
                                            label: const Text('Назначить'),
                                          ),
                                        ],
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
              return const Center(child: Text('Данные не найдены'));
            },
          );
        },
      ),
    );
  }

  void _showAssignSpeakerDialog(BuildContext context) {
    if (_eventId == null) return;
    
    // Загружаем список участников мероприятия
    context.read<EventBloc>().add(LoadEventParticipants(_eventId!, role: UserRole.participant));

    showDialog(
      context: context,
      builder: (context) => BlocBuilder<EventBloc, EventState>(
        builder: (context, state) {
          Profile? selectedProfile;

          return AlertDialog(
            backgroundColor: Theme.of(context).colorScheme.surface,
            surfaceTintColor: Colors.transparent,
            title: const Text('Назначить спикера'),
            content: state is EventLoading
                ? const SizedBox(height: 100, child: Center(child: CircularProgressIndicator()))
                : state is EventParticipantsLoaded
                    ? (state.participants.isEmpty
                        ? const Text('Нет доступных участников для назначения')
                        : StatefulBuilder(
                            builder: (context, setDialogState) => DropdownButtonFormField<Profile>(
                              hint: const Text('Выберите из списка'),
                              items: state.participants.map((p) => DropdownMenuItem(
                                value: p,
                                child: Text(p.fullName),
                              )).toList(),
                              onChanged: (val) => setDialogState(() => selectedProfile = val),
                              decoration: const InputDecoration(labelText: 'Участник'),
                            ),
                          ))
                    : const Text('Ошибка загрузки участников'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Отмена')),
              ElevatedButton(
                onPressed: () {
                  if (selectedProfile != null) {
                    context.read<EventBloc>().add(AssignRoleRequested(
                      eventId: _eventId!,
                      email: selectedProfile!.email,
                      role: UserRole.speaker,
                    ));
                    Navigator.pop(context);
                  }
                },
                child: const Text('Назначить'),
              ),
            ],
          );
        },
      ),
    );
  }
}

String _formatTime(DateTime d) {
  final hh = d.hour.toString().padLeft(2, '0');
  final mm = d.minute.toString().padLeft(2, '0');
  return '$hh:$mm';
}
