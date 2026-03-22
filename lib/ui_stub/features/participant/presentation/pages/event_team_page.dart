import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ready_pro/blocs/auth/auth_bloc.dart';
import 'package:ready_pro/blocs/auth/auth_state.dart';
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
    final authState = context.read<AuthBloc>().state;
    final currentUserId = authState is AuthAuthenticated ? authState.user.id : '';
    final isMe = user.id == currentUserId;

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
        title: Text('${user.fullName}${isMe ? ' (Вы)' : ''}'),
        subtitle: Text(user.company ?? roleLabel),
        trailing: isMe 
          ? null 
          : IconButton(
              icon: const Icon(Icons.chat_bubble_outline),
              onPressed: () => _openChat(user),
              tooltip: 'Написать сообщение',
            ),
      ),
    );
  }

  void _openChat(Profile user) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _TeamChatSheet(recipient: user),
    );
  }
}

class _TeamChatSheet extends StatefulWidget {
  final Profile recipient;
  const _TeamChatSheet({required this.recipient});

  @override
  State<_TeamChatSheet> createState() => _TeamChatSheetState();
}

class _TeamChatSheetState extends State<_TeamChatSheet> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundImage: (widget.recipient.avatarUrl != null && widget.recipient.avatarUrl!.isNotEmpty)
                      ? NetworkImage(widget.recipient.avatarUrl!)
                      : null,
                  child: (widget.recipient.avatarUrl == null || widget.recipient.avatarUrl!.isEmpty)
                      ? const Icon(Icons.person, size: 20)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.recipient.fullName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Expanded(
            child: Center(
              child: Text(
                'История сообщений пока пуста.\nНачните диалог первым!',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 8 + MediaQuery.of(context).viewInsets.bottom),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Введите сообщение...',
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: () {
                    if (_controller.text.trim().isNotEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Сообщение отправлено (заглушка)')),
                      );
                      _controller.clear();
                    }
                  },
                  icon: const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
