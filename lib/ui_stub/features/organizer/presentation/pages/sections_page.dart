import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ready_pro/blocs/organizer/organizer_bloc.dart';
import 'package:ready_pro/blocs/organizer/organizer_event.dart';
import 'package:ready_pro/blocs/organizer/organizer_state.dart';
import 'package:ready_pro/blocs/event/event_bloc.dart';
import 'package:ready_pro/blocs/event/event_event.dart';
import 'package:ready_pro/blocs/event/event_state.dart';
import 'package:ready_pro/models/section.dart';
import 'package:ready_pro/models/user.dart';
import 'package:ready_pro/app/layout/app_breakpoints.dart';

import '../../../../shared/presentation/layout/root_shell.dart';
import '../../../../shared/presentation/widgets/ui_badge.dart';
import '../../../../shared/mock/ui_models.dart';
import '../../../../shared/route_args.dart';

class SectionsPage extends StatefulWidget {
  const SectionsPage({super.key});

  @override
  State<SectionsPage> createState() => _SectionsPageState();
}

class _SectionsPageState extends State<SectionsPage> {
  String? _eventId;
  List<Profile> _participants = [];

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

  String _getCuratorName(String? id) {
    if (id == null) return 'Не назначен';
    try {
      return _participants.firstWhere((p) => p.id == id).fullName;
    } catch (_) {
      return 'ID: $id';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_eventId == null) {
      return const RootShell(
        role: UiRole.organizer,
        title: 'Управление секциями',
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return BlocListener<EventBloc, EventState>(
      listener: (context, state) {
        if (state is EventParticipantsLoaded) {
          setState(() {
            _participants = state.participants;
          });
        }
      },
      child: RootShell(
        role: UiRole.organizer,
        title: 'Управление секциями',
        child: BlocBuilder<OrganizerBloc, OrganizerState>(
          builder: (context, state) {
            if (state is OrganizerLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is OrganizerDashboardLoaded) {
              final sections = state.sections;
              final eventId = state.event.id;

              return Column(
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
                        onPressed: () => _openSectionDialog(context, eventId: eventId),
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Добавить секцию'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  LayoutBuilder(
                    builder: (context, c) {
                      final cols =
                          AppBreakpoints.sectionCardColumns(c.maxWidth);
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
                                            eventId: eventId,
                                          ),
                                          icon: const Icon(Icons.edit_outlined),
                                          tooltip: 'Редактировать',
                                        ),
                                        IconButton(
                                          onPressed: () {
                                            context.read<OrganizerBloc>().add(
                                                  DeleteSection(section.id, eventId),
                                                );
                                          },
                                          icon: const Icon(Icons.delete_outline),
                                          tooltip: 'Удалить',
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    if (section.description != null)
                                      Text(
                                        section.description!,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSurface
                                                  .withValues(alpha: 0.6),
                                            ),
                                      ),
                                    const Spacer(),
                                    const Divider(),
                                    Row(
                                      children: [
                                        const Icon(Icons.groups_outlined, size: 16),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            _getCuratorName(section.curatorId),
                                            style: Theme.of(context).textTheme.bodySmall,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        if (section.curatorId != null)
                                          const UiBadge(
                                            'Куратор',
                                            variant: UiBadgeVariant.secondary,
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Прогресс: ${section.progress}%',
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context).colorScheme.primary,
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
              );
            }
            return const Center(child: Text('Нет данных'));
          },
        ),
      ),
    );
  }

  Future<void> _openSectionDialog(
    BuildContext context, {
    Section? section,
    required String eventId,
  }) async {
    final nameController = TextEditingController(text: section?.name);
    final descController = TextEditingController(text: section?.description);
    Profile? selectedCurator = section?.curatorId != null 
        ? _participants.cast<Profile?>().firstWhere((p) => p?.id == section!.curatorId, orElse: () => null)
        : null;

    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(section == null ? 'Новая секция' : 'Редактировать секцию'),
          content: SizedBox(
            width: 560,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Название секции'),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: descController,
                    maxLines: 3,
                    decoration: const InputDecoration(labelText: 'Описание'),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<Profile>(
                    isExpanded: true,
                    decoration: const InputDecoration(labelText: 'Куратор (выбор из участников)'),
                    items: _participants.map((p) => DropdownMenuItem(
                      value: p,
                      child: Text(p.fullName),
                    )).toList(),
                    onChanged: (val) => setState(() => selectedCurator = val),
                    value: selectedCurator,
                    hint: const Text('Выберите куратора'),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Отмена')),
            FilledButton(
              onPressed: () {
                if (nameController.text.isEmpty) return;

                final newSection = Section(
                  id: section?.id ?? '',
                  eventId: eventId,
                  name: nameController.text,
                  description: descController.text,
                  curatorId: selectedCurator?.id,
                  progress: section?.progress ?? 0,
                );

                if (section == null) {
                  context.read<OrganizerBloc>().add(CreateSection(newSection));
                } else {
                  context.read<OrganizerBloc>().add(UpdateSection(newSection));
                }
                Navigator.pop(ctx);
              },
              child: Text(section == null ? 'Создать' : 'Сохранить'),
            ),
          ],
        ),
      ),
    );
  }
}
