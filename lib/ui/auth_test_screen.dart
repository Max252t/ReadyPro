import 'package:flutter/material.dart';
import 'package:ready_pro/core/di.dart';
import 'package:ready_pro/repositories/auth_repository.dart';
import 'package:ready_pro/repositories/event_repository.dart';
import 'package:ready_pro/repositories/section_repository.dart';
import 'package:ready_pro/repositories/talk_repository.dart';
import 'package:ready_pro/repositories/task_repository.dart';
import 'package:ready_pro/models/user.dart';
import 'package:ready_pro/models/user_event.dart';
import 'package:ready_pro/models/event.dart';
import 'package:ready_pro/models/section.dart';
import 'package:ready_pro/models/talk.dart';
import 'package:ready_pro/models/task.dart';
import 'package:ready_pro/core/enums.dart';

class AuthTestScreen extends StatefulWidget {
  const AuthTestScreen({super.key});

  @override
  State<AuthTestScreen> createState() => _AuthTestScreenState();
}

class _AuthTestScreenState extends State<AuthTestScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  
  final Map<String, TextEditingController> _eventRoleControllers = {};
  final Map<String, TextEditingController> _eventSectionNameControllers = {};
  final Map<String, TextEditingController> _sectionTalkTitleControllers = {};
  final Map<String, TextEditingController> _taskTitleControllers = {};
  
  UserRole _selectedRoleForAssign = UserRole.participant;
  Profile? _currentUser;
  bool _isLoading = false;
  List<UserEvent> _myEvents = [];
  Map<String, List<Section>> _eventSections = {};
  Map<String, List<Talk>> _sectionTalks = {};
  Map<String, List<Task>> _eventTasks = {};
  Map<String, List<Profile>> _eventParticipants = {};

  @override
  void initState() {
    super.initState();
    _checkUser();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    for (var c in _eventRoleControllers.values) c.dispose();
    for (var c in _eventSectionNameControllers.values) c.dispose();
    for (var c in _sectionTalkTitleControllers.values) c.dispose();
    for (var c in _taskTitleControllers.values) c.dispose();
    super.dispose();
  }

  Future<void> _checkUser() async {
    final user = await getIt<AuthRepository>().getCurrentUser();
    if (mounted) {
      setState(() => _currentUser = user);
      if (user != null) _loadMyEvents();
    }
  }

  Future<void> _loadMyEvents() async {
    if (_currentUser == null) return;
    try {
      final events = await getIt<EventRepository>().getUserEvents(_currentUser!.id);
      if (mounted) setState(() => _myEvents = events);
      for (var event in events) {
        _loadSections(event.eventId);
        _loadTasks(event.eventId);
        _loadParticipants(event.eventId);
      }
    } catch (e) {
      print('Network Error: $e');
    }
  }

  Future<void> _loadSections(String eventId) async {
    try {
      final sections = await getIt<SectionRepository>().getSectionsByEvent(eventId);
      if (mounted) {
        setState(() => _eventSections[eventId] = sections);
        for (var section in sections) _loadTalks(section.id);
      }
    } catch (e) {
      print('Error loading sections: $e');
    }
  }

  Future<void> _loadTalks(String sectionId) async {
    try {
      final talks = await getIt<TalkRepository>().getTalksBySection(sectionId);
      if (mounted) setState(() => _sectionTalks[sectionId] = talks);
    } catch (e) {
      print('Error loading talks: $e');
    }
  }

  Future<void> _loadTasks(String eventId) async {
    try {
      final tasks = await getIt<TaskRepository>().getTasksByEvent(eventId);
      if (mounted) setState(() => _eventTasks[eventId] = tasks);
    } catch (e) {
      print('Error loading tasks: $e');
    }
  }

  Future<void> _loadParticipants(String eventId) async {
    try {
      final participants = await getIt<EventRepository>().getEventParticipants(eventId);
      if (mounted) setState(() => _eventParticipants[eventId] = participants);
    } catch (e) {
      print('Error loading participants: $e');
    }
  }

  Future<void> _handleDeleteEvent(String eventId) async {
    try {
      await getIt<EventRepository>().deleteEvent(eventId);
      _loadMyEvents();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Мероприятие удалено')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ошибка удаления: $e')));
    }
  }

  Future<void> _handleAssignRole(String eventId) async {
    final controller = _eventRoleControllers[eventId];
    if (controller == null || controller.text.isEmpty) return;
    try {
      await getIt<EventRepository>().assignRole(eventId: eventId, email: controller.text.trim(), role: _selectedRoleForAssign);
      controller.clear();
      _loadParticipants(eventId);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Роль назначена')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ошибка: $e')));
    }
  }

  Future<void> _handleCreateSection(String eventId) async {
    final controller = _eventSectionNameControllers[eventId];
    if (controller == null || controller.text.isEmpty) return;
    try {
      await getIt<SectionRepository>().createSection(Section(id: '', eventId: eventId, name: controller.text.trim(), progress: 0));
      controller.clear();
      _loadSections(eventId);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ошибка: $e')));
    }
  }

  Future<void> _handleCreateTalk(String sectionId, String eventId) async {
    final controller = _sectionTalkTitleControllers[sectionId];
    if (controller == null || controller.text.isEmpty) return;
    try {
      await getIt<TalkRepository>().createTalk(Talk(id: '', sectionId: sectionId, speakerId: _currentUser!.id, title: controller.text.trim(), status: TalkStatus.draft));
      controller.clear();
      _loadTalks(sectionId);
      _loadSections(eventId);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ошибка: $e')));
    }
  }

  Future<void> _handleCreateTask(String eventId, String assigneeId) async {
    final controller = _taskTitleControllers[eventId];
    if (controller == null || controller.text.isEmpty) return;
    try {
      await getIt<TaskRepository>().createTask(Task(id: '', eventId: eventId, assigneeId: assigneeId, assignerId: _currentUser!.id, title: controller.text.trim(), description: '', dueDate: DateTime.now().add(const Duration(days: 7)), isCompleted: false));
      controller.clear();
      _loadTasks(eventId);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Задача поставлена')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ошибка: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ГотовностьПро: Панель управления')),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : Padding(
            padding: const EdgeInsets.all(16.0),
            child: _currentUser == null ? _buildAuthForm() : _buildMainPanel(),
          ),
    );
  }

  Widget _buildAuthForm() {
    return Column(children: [
      TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'ФИО')),
      TextField(controller: _emailController, decoration: const InputDecoration(labelText: 'Email')),
      TextField(controller: _passwordController, decoration: const InputDecoration(labelText: 'Пароль'), obscureText: true),
      const SizedBox(height: 20),
      Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
        ElevatedButton(onPressed: _handleSignIn, child: const Text('Войти')),
        ElevatedButton(onPressed: _handleSignUp, child: const Text('Регистрация')),
      ]),
    ]);
  }

  Future<void> _handleSignIn() async {
    setState(() => _isLoading = true);
    try {
      final p = await getIt<AuthRepository>().signIn(email: _emailController.text, password: _passwordController.text);
      if (mounted) setState(() { _currentUser = p; _isLoading = false; });
      if (p != null) _loadMyEvents();
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ошибка: $e')));
    }
  }

  Future<void> _handleSignUp() async {
    setState(() => _isLoading = true);
    try {
      final p = await getIt<AuthRepository>().signUp(email: _emailController.text, password: _passwordController.text, fullName: _nameController.text);
      if (mounted) setState(() { _currentUser = p; _isLoading = false; });
      if (p != null) _loadMyEvents();
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ошибка: $e')));
    }
  }

  Widget _buildMainPanel() {
    return Column(
      children: [
        Card(
          child: ListTile(
            leading: CircleAvatar(backgroundImage: _currentUser?.avatarUrl != null && _currentUser!.avatarUrl!.startsWith('http') ? NetworkImage(_currentUser!.avatarUrl!) : null, child: _currentUser?.avatarUrl == null ? const Icon(Icons.person) : null),
            title: Text(_currentUser?.fullName ?? ''),
            subtitle: Text(_currentUser?.email ?? ''),
            trailing: IconButton(icon: const Icon(Icons.logout), onPressed: () => getIt<AuthRepository>().signOut().then((_) => setState(() => _currentUser = null))),
          ),
        ),
        ElevatedButton.icon(
          onPressed: () async {
            final newEvent = Event(id: '', title: 'Ивент ${DateTime.now().second}', status: EventStatus.preparation, createdBy: _currentUser!.id);
            await getIt<EventRepository>().createEvent(newEvent);
            _loadMyEvents();
          }, 
          icon: const Icon(Icons.add),
          label: const Text('Создать мероприятие'),
        ),
        const Divider(),
        Expanded(
          child: ListView.builder(
            itemCount: _myEvents.length,
            itemBuilder: (context, index) {
              final e = _myEvents[index];
              final sections = _eventSections[e.eventId] ?? [];
              final tasks = _eventTasks[e.eventId] ?? [];
              final participants = _eventParticipants[e.eventId] ?? [];
              
              _eventRoleControllers.putIfAbsent(e.eventId, () => TextEditingController());
              _eventSectionNameControllers.putIfAbsent(e.eventId, () => TextEditingController());
              _taskTitleControllers.putIfAbsent(e.eventId, () => TextEditingController());

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ExpansionTile(
                  title: Text(e.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('Роль: ${e.role.name.toUpperCase()}'),
                  trailing: e.role == UserRole.organizer 
                    ? IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _handleDeleteEvent(e.eventId))
                    : null,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (e.role == UserRole.organizer) ...[
                            const Text('Управление доступом (Email):', style: TextStyle(fontSize: 12, color: Colors.grey)),
                            Row(
                              children: [
                                Expanded(child: TextField(controller: _eventRoleControllers[e.eventId], decoration: const InputDecoration(hintText: 'user@example.com'))),
                                DropdownButton<UserRole>(
                                  value: _selectedRoleForAssign,
                                  onChanged: (val) => setState(() => _selectedRoleForAssign = val!),
                                  items: [UserRole.curator, UserRole.speaker, UserRole.participant].map((r) => DropdownMenuItem(value: r, child: Text(r.name))).toList(),
                                ),
                                IconButton(onPressed: () => _handleAssignRole(e.eventId), icon: const Icon(Icons.person_add, color: Colors.blue)),
                              ],
                            ),
                            const Text('Добавить секцию:', style: TextStyle(fontSize: 12, color: Colors.grey)),
                            Row(
                              children: [
                                Expanded(child: TextField(controller: _eventSectionNameControllers[e.eventId], decoration: const InputDecoration(hintText: 'Название секции'))),
                                IconButton(onPressed: () => _handleCreateSection(e.eventId), icon: const Icon(Icons.add_box, color: Colors.green)),
                              ],
                            ),
                            const Divider(),
                          ],
                          const Text('Секции:', style: TextStyle(fontWeight: FontWeight.bold)),
                          ...sections.map((s) {
                            _sectionTalkTitleControllers.putIfAbsent(s.id, () => TextEditingController());
                            final talks = _sectionTalks[s.id] ?? [];
                            return ExpansionTile(
                              title: Text(s.name),
                              trailing: Text('${s.progress}%', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                              children: [
                                if (e.role == UserRole.organizer || e.role == UserRole.curator)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    child: Row(
                                      children: [
                                        Expanded(child: TextField(controller: _sectionTalkTitleControllers[s.id], decoration: const InputDecoration(hintText: 'Добавить доклад'))),
                                        IconButton(onPressed: () => _handleCreateTalk(s.id, e.eventId), icon: const Icon(Icons.playlist_add)),
                                      ],
                                    ),
                                  ),
                                ...talks.map((t) => ListTile(title: Text(t.title), subtitle: Text('Статус: ${t.status.name}'), dense: true)),
                              ],
                            );
                          }).toList(),
                          const Divider(),
                          const Text('Задачи:', style: TextStyle(fontWeight: FontWeight.bold)),
                          ...tasks.map((t) => ListTile(
                            title: Text(t.title),
                            subtitle: Text('Кому: ${participants.firstWhere((p) => p.id == t.assigneeId, orElse: () => Profile(id: '', fullName: 'Загрузка...', email: '')).fullName}'),
                            trailing: Icon(t.isCompleted ? Icons.check_circle : Icons.pending, color: t.isCompleted ? Colors.green : Colors.orange),
                          )),
                          if (e.role == UserRole.organizer || e.role == UserRole.curator) ...[
                            const SizedBox(height: 10),
                            const Text('Поставить задачу:', style: TextStyle(fontSize: 12, color: Colors.grey)),
                            TextField(controller: _taskTitleControllers[e.eventId], decoration: const InputDecoration(hintText: 'Текст задачи')),
                            DropdownButton<String>(
                              hint: const Text('Выберите исполнителя'),
                              isExpanded: true,
                              items: participants.map((p) => DropdownMenuItem(value: p.id, child: Text(p.fullName))).toList(),
                              onChanged: (val) { if (val != null) _handleCreateTask(e.eventId, val); },
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
