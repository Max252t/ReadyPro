import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
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

  Future<void> _pickAvatar() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (pickedFile != null) {
      if (mounted) {
        context.read<AuthBloc>().add(AuthAvatarUpdateRequested(File(pickedFile.path)));
      }
    }
  }

  Future<void> _showEditProfileDialog() async {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return;

    final nameController = TextEditingController(text: authState.user.fullName);
    final companyController = TextEditingController(text: authState.user.company);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Редактировать профиль'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: 'ФИО')),
            const SizedBox(height: 8),
            TextField(controller: companyController, decoration: const InputDecoration(labelText: 'Компания')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Отмена')),
          ElevatedButton(
            onPressed: () {
              context.read<AuthBloc>().add(AuthUpdateProfileRequested(
                fullName: nameController.text.trim(),
                company: companyController.text.trim(),
              ));
              Navigator.pop(context);
            },
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );
  }

  Future<void> _showCreateEventDialog() async {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    File? selectedImage;
    
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Создать мероприятие'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () async {
                    final picker = ImagePicker();
                    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
                    if (pickedFile != null) {
                      setDialogState(() {
                        selectedImage = File(pickedFile.path);
                      });
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                      image: selectedImage != null 
                        ? DecorationImage(image: FileImage(selectedImage!), fit: BoxFit.cover)
                        : const DecorationImage(image: AssetImage('assets/images/event.png'), fit: BoxFit.cover),
                    ),
                    child: selectedImage == null 
                      ? const Center(child: Icon(Icons.add_a_photo, size: 32, color: Colors.grey))
                      : null,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Название')),
                TextField(controller: descController, decoration: const InputDecoration(labelText: 'Описание')),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Отмена')),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.isEmpty) return;
                
                final newEvent = Event(
                  id: '',
                  title: titleController.text,
                  description: descController.text,
                  status: EventStatus.preparation,
                  createdBy: authState.user.id,
                );
                context.read<EventBloc>().add(CreateEventRequested(newEvent, imageFile: selectedImage));
                Navigator.pop(context);
              },
              child: const Text('Создать'),
            ),
          ],
        ),
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
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Ваша информация и активность',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ),
                    const ThemeToggleButton(),
                  ],
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Основная информация', style: TextStyle(fontWeight: FontWeight.bold)),
                            IconButton(onPressed: _showEditProfileDialog, icon: const Icon(Icons.edit, size: 20)),
                          ],
                        ),
                        const Divider(),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final isSmall = constraints.maxWidth < 400;
                            return Wrap(
                              spacing: 16,
                              runSpacing: 16,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                GestureDetector(
                                  onTap: _pickAvatar,
                                  child: Stack(
                                    children: [
                                      CircleAvatar(
                                        radius: 40,
                                        backgroundImage: profile.avatarUrl != null ? NetworkImage(profile.avatarUrl!) : null,
                                        child: profile.avatarUrl == null ? const Icon(Icons.person, size: 40) : null,
                                      ),
                                      Positioned(
                                        right: 0,
                                        bottom: 0,
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(color: Theme.of(context).primaryColor, shape: BoxShape.circle),
                                          child: const Icon(Icons.camera_alt, size: 14, color: Colors.white),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  width: isSmall ? constraints.maxWidth : constraints.maxWidth - 100,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(profile.fullName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                                      Text(profile.email, style: const TextStyle(color: Colors.grey), overflow: TextOverflow.ellipsis),
                                      if (profile.company != null) Text(profile.company!, style: const TextStyle(color: Colors.grey), overflow: TextOverflow.ellipsis),
                                      const SizedBox(height: 8),
                                      UiBadge(_roleLabelRu(widget.role), variant: UiBadgeVariant.secondary),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Мои мероприятия', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    if (widget.role == UiRole.organizer)
                      TextButton.icon(onPressed: _showCreateEventDialog, icon: const Icon(Icons.add), label: const Text('Создать')),
                  ],
                ),
                const SizedBox(height: 12),
                BlocBuilder<EventBloc, EventState>(
                  builder: (context, state) {
                    if (state is EventLoading) return const Center(child: CircularProgressIndicator());
                    if (state is EventsLoaded) {
                      if (state.events.isEmpty) return const Center(child: Text('Нет мероприятий'));
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: state.events.length,
                        itemBuilder: (context, index) {
                          final e = state.events[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: e.imageUrl != null 
                                  ? Image.network(e.imageUrl!, width: 40, height: 40, fit: BoxFit.cover)
                                  : Image.asset('assets/images/event.png', width: 40, height: 40, fit: BoxFit.cover),
                              ),
                              title: Text(e.title, overflow: TextOverflow.ellipsis),
                              subtitle: Text(_userRoleLabelRu(e.role)),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () => _navigateToEvent(context, e.role, e.eventId),
                            ),
                          );
                        },
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
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
