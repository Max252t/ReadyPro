import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ready_pro/blocs/event/event_bloc.dart';
import 'package:ready_pro/blocs/event/event_event.dart';
import 'package:ready_pro/blocs/event/event_state.dart';
import 'package:ready_pro/models/user.dart';
import 'package:ready_pro/core/enums.dart';

import '../../../../shared/mock/ui_models.dart';
import '../../../../shared/presentation/layout/root_shell.dart';
import '../../../../shared/route_args.dart';

class EventTeamPage extends StatefulWidget {
  final UiRole role;

  const EventTeamPage({super.key, required this.role});

  @override
  State<EventTeamPage> createState() => _EventTeamPageState();
}

class _EventTeamPageState extends State<EventTeamPage> {
  String? _eventId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final eventId = eventIdFromArgs(ModalRoute.of(context)?.settings.arguments);
    if (eventId != null && _eventId != eventId) {
      _eventId = eventId;
      context.read<EventBloc>().add(LoadEventParticipants(eventId));
    }
  }

  @override
  Widget build(BuildContext context) {
    return RootShell(
      role: widget.role,
      title: 'Команда мероприятия',
      child: BlocBuilder<EventBloc, EventState>(
        builder: (context, state) {
          if (state is EventLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is EventParticipantsLoaded) {
            final participants = state.participants;
            
            // Фильтруем по ролям
            // Предполагаем, что в Profile или где-то еще есть информация о роли в этом ивенте.
            // Если LoadEventParticipants возвращает всех участников с их ролями:
            final organizers = participants.where((p) => p.role == UserRole.organizer).toList();
            final curators = participants.where((p) => p.role == UserRole.curator).toList();
            final speakers = participants.where((p) => p.role == UserRole.speaker).toList();

            return ListView(
              children: [
                if (organizers.isNotEmpty) ...[
                  _buildSectionTitle('Организаторы'),
                  ...organizers.map((p) => _buildUserTile(p, 'Организатор')),
                ],
                if (curators.isNotEmpty) ...[
                  _buildSectionTitle('Кураторы'),
                  ...curators.map((p) => _buildUserTile(p, 'Куратор')),
                ],
                if (speakers.isNotEmpty) ...[
                  _buildSectionTitle('Спикеры'),
                  ...speakers.map((p) => _buildUserTile(p, 'Спикер')),
                ],
                if (organizers.isEmpty && curators.isEmpty && speakers.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Text('Информация о команде пока недоступна'),
                    ),
                  ),
              ],
            );
          }

          return const Center(child: Text('Не удалось загрузить данные о команде'));
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
      ),
    );
  }

  Widget _buildUserTile(Profile user, String roleLabel) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: (user.avatarUrl != null && user.avatarUrl!.isNotEmpty)
              ? NetworkImage(user.avatarUrl!)
              : null,
          child: (user.avatarUrl == null || user.avatarUrl!.isEmpty)
              ? const Icon(Icons.person)
              : null,
        ),
        title: Text(user.fullName),
        subtitle: Text(user.company ?? roleLabel),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            roleLabel,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
