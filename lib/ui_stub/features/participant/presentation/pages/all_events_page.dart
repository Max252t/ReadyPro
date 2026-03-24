import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ready_pro/blocs/event/event_bloc.dart';
import 'package:ready_pro/blocs/event/event_event.dart';
import 'package:ready_pro/blocs/event/event_state.dart';
import 'package:ready_pro/models/event.dart';
import 'package:ready_pro/core/enums.dart';
import 'package:ready_pro/app/layout/app_breakpoints.dart';

import '../../../../../app/routes.dart';
import '../../../../shared/mock/ui_models.dart';
import '../../../../shared/presentation/layout/root_shell.dart';

class AllEventsPage extends StatefulWidget {
  final UiRole role;

  const AllEventsPage({super.key, required this.role});

  @override
  State<AllEventsPage> createState() => _AllEventsPageState();
}

class _AllEventsPageState extends State<AllEventsPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Event>? _allEvents;

  @override
  void initState() {
    super.initState();
    context.read<EventBloc>().add(LoadAllEvents());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RootShell(
      role: widget.role,
      title: 'Все мероприятия',
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Поиск мероприятий...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        },
                      )
                    : null,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Theme.of(context).cardColor,
              ),
              onChanged: (val) {
                setState(() {});
              },
            ),
          ),
          Expanded(
            child: BlocBuilder<EventBloc, EventState>(
              buildWhen: (previous, current) {
                return current is AllEventsLoaded || current is EventLoading || current is EventFailure;
              },
              builder: (context, state) {
                if (state is AllEventsLoaded) {
                  _allEvents = state.events;
                }

                if (_allEvents == null && state is EventLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is EventFailure && _allEvents == null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 48, color: Colors.red),
                        const SizedBox(height: 16),
                        Text('Ошибка: ${state.message}'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => context.read<EventBloc>().add(LoadAllEvents()),
                          child: const Text('Повторить'),
                        ),
                      ],
                    ),
                  );
                }

                if (_allEvents != null) {
                  var filtered = _allEvents!;
                  if (_searchController.text.isNotEmpty) {
                    filtered = filtered
                        .where((e) => e.title.toLowerCase().contains(_searchController.text.toLowerCase()))
                        .toList();
                  }

                  if (filtered.isEmpty) {
                    return const Center(child: Text('Ничего не найдено'));
                  }

                  return LayoutBuilder(
                    builder: (context, constraints) {
                      final crossAxisCount = AppBreakpoints.twoColumnCards(constraints.maxWidth);
                      
                      if (crossAxisCount > 1) {
                        return GridView.builder(
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 1.4,
                          ),
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            return _EventCard(event: filtered[index], role: widget.role, isGrid: true);
                          },
                        );
                      }

                      return ListView.builder(
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          return _EventCard(event: filtered[index], role: widget.role, isGrid: false);
                        },
                      );
                    }
                  );
                }

                return const Center(child: CircularProgressIndicator());
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  final Event event;
  final UiRole role;
  final bool isGrid;

  const _EventCard({required this.event, required this.role, required this.isGrid});

  @override
  Widget build(BuildContext context) {
    final cardContent = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildImage(context),
        _buildDetails(context),
      ],
    );

    return Card(
      margin: isGrid ? EdgeInsets.zero : const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            AppRoutes.eventDetails,
            arguments: {'eventId': event.id, 'role': role},
          );
        },
        child: isGrid ? cardContent : cardContent,
      ),
    );
  }

  Widget _buildImage(BuildContext context) {
    final imageWidget = Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: (event.imageUrl != null && event.imageUrl!.isNotEmpty)
              ? NetworkImage(event.imageUrl!)
              : const AssetImage('assets/images/event.png') as ImageProvider,
          fit: BoxFit.cover,
        ),
      ),
    );

    final content = Stack(
      fit: StackFit.expand,
      children: [
        imageWidget,
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
              _getStatusLabel(event.status),
              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );

    if (isGrid) {
      return Expanded(flex: 3, child: content);
    }
    return SizedBox(height: 180, width: double.infinity, child: content);
  }

  Widget _buildDetails(BuildContext context) {
    final content = Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            event.title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          if (event.description != null)
            Text(
              event.description!,
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          if (!isGrid) const SizedBox(height: 12) else const Spacer(),
          Row(
            children: [
              if (event.startDate != null)
                Expanded(
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 14, color: Colors.blue),
                      const SizedBox(width: 4),
                      Text(
                        '${event.startDate!.day}.${event.startDate!.month}.${event.startDate!.year}',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              if (event.location != null && event.location!.isNotEmpty)
                Expanded(
                  child: Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 14, color: Colors.red),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          event.location!,
                          style: const TextStyle(fontSize: 12),
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
    );

    if (isGrid) {
      return Expanded(flex: 2, child: content);
    }
    return content;
  }

  String _getStatusLabel(EventStatus status) {
    switch (status) {
      case EventStatus.active:
        return 'Идёт сейчас';
      case EventStatus.preparation:
        return 'Подготовка';
      case EventStatus.finished:
        return 'Завершено';
      default:
        return 'Скоро';
    }
  }
}
