import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ready_pro/blocs/event/event_bloc.dart';
import 'package:ready_pro/blocs/event/event_event.dart';
import 'package:ready_pro/blocs/event/event_state.dart';
import 'package:ready_pro/models/event.dart';
import 'package:ready_pro/core/enums.dart';

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

  @override
  void initState() {
    super.initState();
    // Принудительно загружаем список всех мероприятий при входе на экран
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
              builder: (context, state) {
                // Если мы в процессе загрузки или в начальном состоянии, всегда показываем лоадер
                if (state is EventLoading || state is EventInitial) {
                  return const Center(child: CircularProgressIndicator());
                }

                // Обработка ошибок
                if (state is EventFailure) {
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

                // Отображаем список только если состояние AllEventsLoaded
                if (state is AllEventsLoaded) {
                  final events = state.events;

                  if (events.isEmpty) {
                    return const Center(child: Text('Мероприятий пока нет'));
                  }

                  var filtered = events;
                  if (_searchController.text.isNotEmpty) {
                    filtered = filtered
                        .where((e) => e.title.toLowerCase().contains(_searchController.text.toLowerCase()))
                        .toList();
                  }

                  if (filtered.isEmpty) {
                    return const Center(child: Text('По вашему запросу ничего не найдено'));
                  }

                  return ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final event = filtered[index];
                      return _EventCard(event: event, role: widget.role);
                    },
                  );
                }

                // Если состояние другое (например, EventsLoaded от другого экрана), 
                // показываем лоадер, так как мы ожидаем AllEventsLoaded для этого экрана
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

  const _EventCard({required this.event, required this.role});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  height: 160,
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
                      _getStatusLabel(event.status),
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
