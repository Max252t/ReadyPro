import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ready_pro/app/routes.dart';
import 'package:ready_pro/blocs/auth/auth_bloc.dart';
import 'package:ready_pro/blocs/auth/auth_state.dart';
import 'package:ready_pro/blocs/event/event_bloc.dart';
import 'package:ready_pro/blocs/event/event_event.dart';
import 'package:ready_pro/models/event.dart';

import '../../../../shared/mock/ui_models.dart';

class EventDetailsPage extends StatefulWidget {
  final String eventId;
  final UiRole role;

  const EventDetailsPage({
    super.key,
    required this.eventId,
    this.role = UiRole.participant,
  });

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

  PreferredSizeWidget _buildAppBar(BuildContext context, {String? title}) {
    final canPop = Navigator.canPop(context);
    return AppBar(
      title: Text(title ?? 'Мероприятие'),
      leading: canPop
          ? IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.maybePop(context),
            )
          : null,
      automaticallyImplyLeading: false,
      actions: [
        IconButton(
          icon: const Icon(Icons.home_outlined),
          tooltip: 'На главную',
          onPressed: () => AppRoutes.navigateToRoleHome(context, widget.role),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: _buildAppBar(context),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_event == null) {
      return Scaffold(
        appBar: _buildAppBar(context),
        body: const Center(child: Text('Мероприятие не найдено')),
      );
    }

    return Scaffold(
      appBar: _buildAppBar(context, title: _event!.title),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: 200,
              child: _event!.imageUrl != null
                  ? Image.network(
                      _event!.imageUrl!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: 200,
                      errorBuilder: (_, __, ___) {
                        return Image.asset(
                          'assets/images/event.png',
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: 200,
                        );
                      },
                    )
                  : Image.asset(
                      'assets/images/event.png',
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: 200,
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
