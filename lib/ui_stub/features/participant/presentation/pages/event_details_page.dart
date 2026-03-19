import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ready_pro/blocs/auth/auth_bloc.dart';
import 'package:ready_pro/blocs/auth/auth_state.dart';
import 'package:ready_pro/blocs/event/event_bloc.dart';
import 'package:ready_pro/blocs/event/event_event.dart';
import 'package:ready_pro/blocs/event/event_state.dart';
import 'package:ready_pro/models/event.dart';
import 'package:ready_pro/core/enums.dart';

class EventDetailsPage extends StatefulWidget {
  final String eventId;

  const EventDetailsPage({super.key, required this.eventId});

  @override
  State<EventDetailsPage> createState() => _EventDetailsPageState();
}

class _EventDetailsPageState extends State<EventDetailsPage> {
  Event? _event;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEvent();
  }

  Future<void> _loadEvent() async {
    // We could use a specific event for this, but for now we'll find it in AllEvents if loaded
    // or fetch by ID if we add that to the repository.
    // Assuming EventBloc might need a "LoadEventById" but let's check repository.
    // Repository HAS getEventById. Let's use it.
    try {
      final event = await context.read<EventBloc>().getEventById(widget.eventId);
      if (mounted) {
        setState(() {
          _event = event;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ошибка загрузки: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_event == null) {
      return const Scaffold(body: Center(child: Text('Мероприятие не найдено')));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_event!.title),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: _event!.imageUrl != null
                      ? NetworkImage(_event!.imageUrl!)
                      : const AssetImage('assets/images/event.png') as ImageProvider,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _event!.title,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  if (_event!.startDate != null)
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 18, color: Colors.grey),
                        const SizedBox(width: 8),
                        Text(
                          '${_event!.startDate!.day}.${_event!.startDate!.month}.${_event!.startDate!.year}',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  const SizedBox(height: 16),
                  Text(
                    'Описание',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(_event!.description ?? 'Нет описания'),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        final authState = context.read<AuthBloc>().state;
                        if (authState is AuthAuthenticated) {
                          context.read<EventBloc>().add(JoinEventRequested(
                                eventId: _event!.id,
                                userId: authState.user.id,
                              ));
                          Navigator.pop(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Записаться как участник'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Note: I need to add getEventById to EventBloc or just call repository directly if possible.
// Better to add it to EventBloc state or just use repository via context if registered.
extension EventBlocHelper on BuildContext {
  // Simple helper to get event from repository
  // In a real BLoC pattern, this should be an event/state
}

// I will add a method to EventBloc to fetch a single event or just use the repository.
