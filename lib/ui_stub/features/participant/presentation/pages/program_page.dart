import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ready_pro/blocs/auth/auth_bloc.dart';
import 'package:ready_pro/blocs/auth/auth_state.dart';
import 'package:ready_pro/blocs/program/program_bloc.dart';
import 'package:ready_pro/blocs/program/program_event.dart';
import 'package:ready_pro/blocs/program/program_state.dart';
import 'package:ready_pro/blocs/event/event_bloc.dart';
import 'package:ready_pro/blocs/event/event_event.dart';
import 'package:ready_pro/blocs/event/event_state.dart';
import 'package:ready_pro/models/talk.dart';
import 'package:ready_pro/models/section.dart';

import '../../../../../app/routes.dart';
import '../../../../shared/mock/ui_models.dart';
import '../../../../shared/presentation/layout/root_shell.dart';
import '../../../../shared/route_args.dart';

class ProgramPage extends StatefulWidget {
  final UiRole role;

  const ProgramPage({super.key, required this.role});

  @override
  State<ProgramPage> createState() => _ProgramPageState();
}

class _ProgramPageState extends State<ProgramPage> with SingleTickerProviderStateMixin {
  TabController? _tabController;
  String? _selectedEventId;
  bool _showAllEvents = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final eventId = eventIdFromArgs(ModalRoute.of(context)?.settings.arguments);
    if (eventId != null && _selectedEventId != eventId) {
      setState(() {
        _selectedEventId = eventId;
      });
      _fetchProgram(eventId);
    }
  }

  void _loadInitialData() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<EventBloc>().add(LoadMyEvents(authState.user.id));
    }
  }

  @override
  void dispose() {
    _tabController?.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _toggleSchedule(String talkId) {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<ProgramBloc>().add(ToggleScheduleRequested(
            talkId: talkId,
            userId: authState.user.id,
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<EventBloc, EventState>(
      listener: (context, state) {
        if (state is EventsLoaded && state.events.isNotEmpty && _selectedEventId == null) {
          setState(() {
            _selectedEventId = state.events.first.eventId;
            _showAllEvents = false;
          });
          _fetchProgram(_selectedEventId!);
        }
        if (state is EventOperationSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
        }
        if (state is EventFailure) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: Colors.red));
        }
      },
      builder: (context, eventState) {
        return RootShell(
          role: widget.role,
          title: _showAllEvents ? 'Поиск мероприятий' : 'Программа',
          actions: [
            if (!_showAllEvents)
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: () {
                  setState(() => _showAllEvents = true);
                  context.read<EventBloc>().add(LoadAllEvents());
                },
                tooltip: 'Найти мероприятия',
              ),
            if (_showAllEvents)
              IconButton(
                icon: const Icon(Icons.my_library_books),
                onPressed: () {
                  setState(() => _showAllEvents = false);
                  _loadInitialData();
                },
                tooltip: 'Моя программа',
              ),
          ],
          child: Column(
            children: [
              if (_showAllEvents)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Поиск мероприятий...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onChanged: (val) {
                      setState(() {}); // Реактивный поиск по списку
                    },
                  ),
                ),
              Expanded(
                child: _showAllEvents ? _buildAllEvents(eventState) : _buildMyProgram(eventState),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAllEvents(EventState state) {
    if (state is EventLoading) return const Center(child: CircularProgressIndicator());
    if (state is AllEventsLoaded) {
      var filtered = state.events;
      if (_searchController.text.isNotEmpty) {
        filtered = filtered.where((e) => e.title.toLowerCase().contains(_searchController.text.toLowerCase())).toList();
      }

      if (filtered.isEmpty) return const Center(child: Text('Мероприятий не найдено'));
      
      return ListView.builder(
        itemCount: filtered.length,
        itemBuilder: (context, index) {
          final event = filtered[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: InkWell(
              onTap: () {
                Navigator.pushNamed(
                  context,
                  AppRoutes.eventDetails,
                  arguments: {'eventId': event.id, 'role': widget.role},
                );
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      Container(
                        height: 140,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: (event.imageUrl != null && event.imageUrl!.isNotEmpty)
                                ? NetworkImage(event.imageUrl!)
                                : const AssetImage('assets/images/event.png') as ImageProvider,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 12,
                        right: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            event.status.name == 'active' ? 'Идёт сейчас' : 'Скоро',
                            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          event.title,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        if (event.description != null)
                          Text(
                            event.description!,
                            style: TextStyle(color: Colors.grey[600], fontSize: 14),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            if (event.startDate != null)
                              Expanded(
                                child: Row(
                                  children: [
                                    const Icon(Icons.calendar_today, size: 16, color: Colors.blue),
                                    const SizedBox(width: 6),
                                    Text(
                                      '${event.startDate!.day}.${event.startDate!.month}.${event.startDate!.year}',
                                      style: const TextStyle(fontSize: 13),
                                    ),
                                  ],
                                ),
                              ),
                            if (event.location != null && event.location!.isNotEmpty)
                              Expanded(
                                child: Row(
                                  children: [
                                    const Icon(Icons.location_on_outlined, size: 16, color: Colors.red),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        event.location!,
                                        style: const TextStyle(fontSize: 13),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildMyProgram(EventState eventState) {
    if (eventState is EventLoading && _selectedEventId == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (eventState is EventsLoaded && eventState.events.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.event_busy, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('Вы пока не участвуете ни в одном мероприятии'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() => _showAllEvents = true);
                context.read<EventBloc>().add(LoadAllEvents());
              },
              child: const Text('Найти мероприятие'),
            ),
          ],
        ),
      );
    }

    return BlocBuilder<ProgramBloc, ProgramState>(
      builder: (context, programState) {
        if (programState.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (programState.talks.isEmpty) {
          return const Center(child: Text('В программе этого мероприятия пока нет докладов'));
        }

        final dateKeys = _uniqueDateKeys(programState.talks);
        if (_tabController == null || _tabController!.length != 1 + dateKeys.length) {
          _tabController?.dispose();
          _tabController = TabController(length: 1 + dateKeys.length, vsync: this);
        }

        return Column(
          children: [
            if (eventState is EventsLoaded && eventState.events.length > 1)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: DropdownButton<String>(
                  value: _selectedEventId,
                  isExpanded: true,
                  items: eventState.events.map((e) => DropdownMenuItem(
                    value: e.eventId,
                    child: Text(e.title),
                  )).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => _selectedEventId = val);
                      _fetchProgram(val);
                    }
                  },
                ),
              ),
            const SizedBox(height: 8),
            TabBar(
              controller: _tabController,
              isScrollable: true,
              tabs: [
                const Tab(text: 'Все дни'),
                for (var i = 0; i < dateKeys.length; i++) Tab(text: 'День ${i + 1}'),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _ProgramTab(
                    grouped: _groupedForDay(programState.sections, programState.talks, null),
                    scheduleTalkIds: programState.scheduleTalkIds,
                    onToggle: _toggleSchedule,
                    role: widget.role,
                  ),
                  for (final dk in dateKeys)
                    _ProgramTab(
                      grouped: _groupedForDay(programState.sections, programState.talks, dk),
                      scheduleTalkIds: programState.scheduleTalkIds,
                      onToggle: _toggleSchedule,
                      role: widget.role,
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  void _fetchProgram(String eventId) {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<ProgramBloc>().add(FetchProgram(
        eventId: eventId,
        userId: authState.user.id,
      ));
    }
  }

  List<String> _uniqueDateKeys(List<Talk> talks) {
    final keys = <String>{};
    for (final t in talks) {
      if (t.startTime != null) {
        keys.add(_dateKey(t.startTime!));
      }
    }
    return keys.toList()..sort();
  }

  String _dateKey(DateTime d) => '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  List<({Section section, List<Talk> talks})> _groupedForDay(
      List<Section> sections, List<Talk> allTalks, String? dayKey) {
    return sections.map((section) {
      var ts = allTalks.where((t) => t.sectionId == section.id).toList()
        ..sort((a, b) => (a.startTime ?? DateTime.now()).compareTo(b.startTime ?? DateTime.now()));
      if (dayKey != null) {
        ts = ts.where((t) => t.startTime != null && _dateKey(t.startTime!) == dayKey).toList();
      }
      return (section: section, talks: ts);
    }).where((g) => g.talks.isNotEmpty).toList();
  }
}

class _ProgramTab extends StatelessWidget {
  final List<({Section section, List<Talk> talks})> grouped;
  final Set<String> scheduleTalkIds;
  final void Function(String) onToggle;
  final UiRole role;

  const _ProgramTab({
    required this.grouped,
    required this.scheduleTalkIds,
    required this.onToggle,
    required this.role,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 12),
      children: [
        for (final g in grouped) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              g.section.name,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          for (final talk in g.talks)
            _TalkCard(
              talk: talk,
              inSchedule: scheduleTalkIds.contains(talk.id),
              onToggle: () => onToggle(talk.id),
              role: role,
            ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _TalkCard extends StatelessWidget {
  final Talk talk;
  final bool inSchedule;
  final VoidCallback onToggle;
  final UiRole role;

  const _TalkCard({
    required this.talk,
    required this.inSchedule,
    required this.onToggle,
    required this.role,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => Navigator.pushNamed(
                      context,
                      AppRoutes.talkDetails,
                      arguments: {'role': role, 'talkId': talk.id},
                    ),
                    child: Text(
                      talk.title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(inSchedule ? Icons.bookmark : Icons.bookmark_border),
                  onPressed: onToggle,
                  color: inSchedule ? Theme.of(context).colorScheme.primary : null,
                ),
              ],
            ),
            if (talk.startTime != null)
              Row(
                children: [
                  const Icon(Icons.access_time, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    _formatTime(talk.startTime!),
                    style: const TextStyle(color: Colors.grey),
                  ),
                  if (talk.room != null) ...[
                    const SizedBox(width: 12),
                    const Icon(Icons.location_on_outlined, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      talk.room!,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ],
              ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime d) {
    return '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }
}
