import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ready_pro/blocs/auth/auth_bloc.dart';
import 'package:ready_pro/blocs/auth/auth_event.dart';
import 'package:ready_pro/blocs/auth/auth_state.dart';
import 'package:ready_pro/blocs/event/event_bloc.dart';
import 'package:ready_pro/blocs/event/event_event.dart';
import 'package:ready_pro/blocs/event/event_state.dart';
import 'package:ready_pro/core/enums.dart';
import 'package:ready_pro/models/event.dart';

import '../../../../../app/routes.dart';
import '../../../../../app/widgets/theme_toggle_button.dart';
import '../../../../shared/presentation/layout/root_shell.dart';
import '../../../../shared/presentation/widgets/ui_badge.dart';
import '../../../../shared/mock/ui_models.dart';

class ProfilePage extends StatefulWidget {
  final UiRole role;

  const ProfilePage({super.key, required this.role});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<EventBloc>().add(LoadMyEvents(authState.user.id));
    }
  }

  Future<void> _showCreateEventDialog() async {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Создать мероприятие'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Название')),
            TextField(controller: descController, decoration: const InputDecoration(labelText: 'Описание')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Отмена')),
          ElevatedButton(
            onPressed: () {
              final newEvent = Event(
                id: '',
                title: titleController.text,
                description: descController.text,
                status: EventStatus.preparation,
                createdBy: authState.user.id,
              );
              context.read<EventBloc>().add(CreateEventRequested(newEvent));
              Navigator.pop(context);
            },
            child: const Text('Создать'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        if (authState is! AuthAuthenticated) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final profile = authState.user;

        return RootShell(
          role: widget.role,
          title: 'Профиль',
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        'Ваша информация и активность',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.6),
                            ),
                      ),
                    ),
                    const ThemeToggleButton(),
                  ],
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.account_circle_outlined, size: 22),
                            const SizedBox(width: 8),
                            Text(
                              'Основная информация',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ],
                        ),
                        const Divider(height: 28),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              radius: 36,
                              backgroundColor:
                                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
                              backgroundImage: profile.avatarUrl != null 
                                ? NetworkImage(profile.avatarUrl!) 
                                : null,
                              child: profile.avatarUrl == null 
                                ? Icon(
                                    Icons.person,
                                    size: 36,
                                    color: Theme.of(context).colorScheme.primary,
                                  )
                                : null,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    profile.fullName,
                                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      Icon(Icons.mail_outline, size: 16, color: Theme.of(context).hintColor),
                                      const SizedBox(width: 6),
                                      Expanded(child: Text(profile.email)),
                                    ],
                                  ),
                                  if (profile.company != null && profile.company!.isNotEmpty) ...[
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        Icon(Icons.work_outline, size: 16, color: Theme.of(context).hintColor),
                                        const SizedBox(width: 6),
                                        Expanded(child: Text(profile.company!)),
                                      ],
                                    ),
                                  ],
                                  const SizedBox(height: 8),
                                  UiBadge(_roleLabelRu(widget.role), variant: UiBadgeVariant.secondary),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Мои мероприятия',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Row(
                      children: [
                        if (widget.role == UiRole.organizer)
                          TextButton.icon(
                            onPressed: _showCreateEventDialog,
                            icon: const Icon(Icons.add),
                            label: const Text('Создать'),
                          ),
                        IconButton(onPressed: _refresh, icon: const Icon(Icons.refresh)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                BlocBuilder<EventBloc, EventState>(
                  builder: (context, state) {
                    if (state is EventLoading) {
                      return const Center(child: Padding(
                        padding: EdgeInsets.all(20.0),
                        child: CircularProgressIndicator(),
                      ));
                    }
                    if (state is EventsLoaded) {
                      if (state.events.isEmpty) {
                        return const Center(child: Text('Вы еще не участвуете в мероприятиях'));
                      }
                      return Column(
                        children: state.events.map((e) => Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: Theme.of(context).colorScheme.primaryContainer,
                              ),
                              child: e.imageUrl != null 
                                ? Image.network(e.imageUrl!, fit: BoxFit.cover)
                                : const Icon(Icons.event),
                            ),
                            title: Text(e.title),
                            subtitle: Text('Роль: ${_userRoleLabelRu(e.role)}'),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () {
                              _navigateToEvent(context, e.role, e.eventId);
                            },
                          ),
                        )).toList(),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      context.read<AuthBloc>().add(AuthSignOutRequested());
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        AppRoutes.login,
                        (_) => false,
                      );
                    },
                    icon: const Icon(Icons.logout),
                    label: const Text('Выйти'),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      },
    );
  }

  void _navigateToEvent(BuildContext context, UserRole role, String eventId) {
    final uiRole = _mapRole(role);
    final args = {'role': uiRole, 'eventId': eventId};

    switch (role) {
      case UserRole.organizer:
        Navigator.pushNamed(context, AppRoutes.organizerDashboard, arguments: args);
        break;
      case UserRole.curator:
        Navigator.pushNamed(context, AppRoutes.curatorDashboard, arguments: args);
        break;
      case UserRole.speaker:
        Navigator.pushNamed(context, AppRoutes.speakerTalks, arguments: args);
        break;
      case UserRole.participant:
        Navigator.pushNamed(context, AppRoutes.participantProgram, arguments: args);
        break;
    }
  }

  UiRole _mapRole(UserRole role) {
    switch (role) {
      case UserRole.organizer: return UiRole.organizer;
      case UserRole.curator: return UiRole.curator;
      case UserRole.speaker: return UiRole.speaker;
      case UserRole.participant: return UiRole.participant;
    }
  }
}

String _roleLabelRu(UiRole r) {
  switch (r) {
    case UiRole.organizer: return 'Организатор';
    case UiRole.curator: return 'Куратор';
    case UiRole.speaker: return 'Спикер';
    case UiRole.participant: return 'Участник';
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
