import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ready_pro/core/di.dart';
import 'package:ready_pro/repositories/auth_repository.dart';
import 'package:ready_pro/repositories/event_repository.dart';
import 'package:ready_pro/repositories/section_repository.dart';
import 'package:ready_pro/repositories/talk_repository.dart';
import 'package:ready_pro/repositories/task_repository.dart';
import 'package:ready_pro/repositories/feedback_repository.dart';
import 'package:ready_pro/repositories/schedule_repository.dart';
import 'package:ready_pro/models/user.dart';
import 'package:ready_pro/models/user_event.dart';
import 'package:ready_pro/models/event.dart';
import 'package:ready_pro/models/section.dart';
import 'package:ready_pro/models/talk.dart';
import 'package:ready_pro/models/task.dart';
import 'package:ready_pro/models/feedback.dart' as model;
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
  Map<String, List<model.Feedback>> _talkFeedbacks = {};
  Map<String, bool> _isInSchedule = {};

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
      print('Error: $e');
    }
  }

  Future<void> _loadTalks(String sectionId) async {
    try {
      final talks = await getIt<TalkRepository>().getTalksBySection(sectionId);
      if (mounted) setState(() => _sectionTalks[sectionId] = talks);
      for (var talk in talks) {
        _loadFeedback(talk.id);
        _loadScheduleStatus(talk.id);
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> _loadScheduleStatus(String talkId) async {
    if (_currentUser == null) return;
    try {
      final isIn = await getIt<ScheduleRepository>().isInSchedule(_currentUser!.id, talkId);
      if (mounted) setState(() => _isInSchedule[talkId] = isIn);
    } catch (e) {
      print('Error loading schedule: $e');
    }
  }

  Future<void> _loadFeedback(String talkId) async {
    try {
      final feed = await getIt<FeedbackRepository>().getFeedbackByTalk(talkId);
      if (mounted) setState(() => _talkFeedbacks[talkId] = feed);
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> _loadTasks(String eventId) async {
    try {
      final tasks = await getIt<TaskRepository>().getTasksByEvent(eventId);
      if (mounted) setState(() => _eventTasks[eventId] = tasks);
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> _loadParticipants(String eventId) async {
    try {
      final participants = await getIt<EventRepository>().getEventParticipants(eventId);
      if (mounted) setState(() => _eventParticipants[eventId] = participants);
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      setState(() => _isLoading = true);
      try {
        final newUrl = await getIt<AuthRepository>().updateAvatar(image);
        if (newUrl != null) {
          await _checkUser();
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Аватар обновлен')));
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ошибка аватара: $e')));
      } finally {
        setState(() => _isLoading = false);
      }
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

  Future<void> _toggleSchedule(Talk talk) async {
    if (_currentUser == null) return;
    try {
      final isIn = _isInSchedule[talk.id] ?? false;
      if (isIn) {
        await getIt<ScheduleRepository>().removeFromSchedule(_currentUser!.id, talk.id);
      } else {
        await getIt<ScheduleRepository>().addToSchedule(_currentUser!.id, talk.id);
      }
      _loadScheduleStatus(talk.id);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ошибка расписания: $e')));
    }
  }

  void _showFeedbackDialog(Talk talk) {
    int rating = 5;
    final commentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Отзыв: ${talk.title}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) => IconButton(
                  icon: Icon(index < rating ? Icons.star : Icons.star_border, color: Colors.amber),
                  onPressed: () => setDialogState(() => rating = index + 1),
                )),
              ),
              TextField(
                controller: commentController,
                decoration: const InputDecoration(labelText: 'Комментарий'),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Отмена')),
            ElevatedButton(
              onPressed: () async {
                try {
                  await getIt<FeedbackRepository>().submitFeedback(model.Feedback(
                    id: '',
                    talkId: talk.id,
                    userId: _currentUser!.id,
                    rating: rating,
                    comment: commentController.text,
                  ));
                  if (mounted) {
                    Navigator.pop(context);
                    _loadFeedback(talk.id);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Отзыв отправлен')));
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                }
              },
              child: const Text('Отправить'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickAndCreateEvent() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    
    setState(() => _isLoading = true);
    try {
      String? imageUrl;
      final tempId = DateTime.now().millisecondsSinceEpoch.toString();
      
      if (image != null) {
        imageUrl = await getIt<EventRepository>().uploadEventImage(tempId, image);
      }

      final newEvent = Event(
        id: '', 
        title: 'Ивент ${DateTime.now().second}', 
        status: EventStatus.preparation, 
        createdBy: _currentUser!.id,
        imageUrl: imageUrl,
      );
      
      final createdEventId = await getIt<EventRepository>().createEvent(newEvent);
      await getIt<EventRepository>().joinEvent(
        eventId: createdEventId,
        userId: _currentUser!.id,
        role: UserRole.organizer,
      );
      _loadMyEvents();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ошибка создания: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ГотовностьПро: Полное управление')),
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
            leading: GestureDetector(
              onTap: _pickAndUploadImage,
              child: CircleAvatar(
                backgroundImage: _currentUser?.avatarUrl != null && _currentUser!.avatarUrl!.startsWith('http') 
                    ? NetworkImage(_currentUser!.avatarUrl!) 
                    : null,
                child: _currentUser?.avatarUrl == null ? const Icon(Icons.add_a_photo) : null,
              ),
            ),
            title: Text(_currentUser?.fullName ?? ''),
            subtitle: const Text('Нажмите на аватар, чтобы изменить'),
            trailing: IconButton(icon: const Icon(Icons.logout), onPressed: () => getIt<AuthRepository>().signOut().then((_) => setState(() => _currentUser = null))),
          ),
        ),
        ElevatedButton.icon(
          onPressed: _pickAndCreateEvent, 
          icon: const Icon(Icons.add_a_photo),
          label: const Text('Создать мероприятие с фото'),
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

              // Находим данные ивента (нам нужно поле image_url, которого нет в UserEvent)
              // В реальном приложении мы бы загружали детали ивента отдельно или расширили UserEvent
              // Для теста предположим, что мы можем получить image_url (нужно добавить его в UserEvent или грузить Event)
              
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ExpansionTile(
                  leading: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                        image: (e.imageUrl != null && e.imageUrl!.isNotEmpty)
                            ? NetworkImage(e.imageUrl!) as ImageProvider
                            : const AssetImage('assets/images/event.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
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
                            const Text('Управление доступом:', style: TextStyle(fontSize: 12, color: Colors.grey)),
                            Row(children: [
                              Expanded(child: TextField(controller: _eventRoleControllers[e.eventId], decoration: const InputDecoration(hintText: 'Email'))),
                              DropdownButton<UserRole>(
                                value: _selectedRoleForAssign,
                                onChanged: (val) => setState(() => _selectedRoleForAssign = val!),
                                items: [UserRole.curator, UserRole.speaker, UserRole.participant].map((r) => DropdownMenuItem(value: r, child: Text(r.name))).toList(),
                              ),
                              IconButton(onPressed: () => _handleAssignRole(e.eventId), icon: const Icon(Icons.person_add, color: Colors.blue)),
                            ]),
                            const Text('Новая секция:', style: TextStyle(fontSize: 12, color: Colors.grey)),
                            Row(children: [
                              Expanded(child: TextField(controller: _eventSectionNameControllers[e.eventId], decoration: const InputDecoration(hintText: 'Название'))),
                              IconButton(onPressed: () => _handleCreateSection(e.eventId), icon: const Icon(Icons.add_box, color: Colors.green)),
                            ]),
                            const Divider(),
                          ],
                          const Text('Секции и доклады:', style: TextStyle(fontWeight: FontWeight.bold)),
                          ...sections.map((s) {
                            _sectionTalkTitleControllers.putIfAbsent(s.id, () => TextEditingController());
                            final talks = _sectionTalks[s.id] ?? [];
                            return ExpansionTile(
                              title: Text(s.name),
                              trailing: Text('${s.progress}%', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                              children: [
                                if (e.role == UserRole.organizer || e.role == UserRole.curator)
                                  Row(children: [
                                    Expanded(child: TextField(controller: _sectionTalkTitleControllers[s.id], decoration: const InputDecoration(hintText: 'Добавить доклад'))),
                                    IconButton(onPressed: () {
                                      getIt<TalkRepository>().createTalk(Talk(id: '', sectionId: s.id, speakerId: _currentUser!.id, title: _sectionTalkTitleControllers[s.id]!.text, status: TalkStatus.draft))
                                      .then((_) { _sectionTalkTitleControllers[s.id]!.clear(); _loadTalks(s.id); _loadSections(e.eventId); });
                                    }, icon: const Icon(Icons.playlist_add)),
                                  ]),
                                ...talks.map((t) {
                                  final inSchedule = _isInSchedule[t.id] ?? false;
                                  return ListTile(
                                    title: Text(t.title), 
                                    subtitle: Text('Статус: ${t.status.name}'), 
                                    dense: true,
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: Icon(inSchedule ? Icons.calendar_today : Icons.calendar_today_outlined, color: inSchedule ? Colors.blue : null),
                                          onPressed: () => _toggleSchedule(t),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.star, color: Colors.amber),
                                          onPressed: () => _showFeedbackDialog(t),
                                        ),
                                      ],
                                    ),
                                  );
                                }),
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
                          if (e.role == UserRole.organizer || e.role == UserRole.curator)
                            DropdownButton<String>(
                              hint: const Text('Поставить задачу участнику'),
                              isExpanded: true,
                              items: participants.map((p) => DropdownMenuItem(value: p.id, child: Text(p.fullName))).toList(),
                              onChanged: (val) { if (val != null) {
                                getIt<TaskRepository>().createTask(Task(id: '', eventId: e.eventId, assigneeId: val, assignerId: _currentUser!.id, title: _taskTitleControllers[e.eventId]!.text, description: '', dueDate: DateTime.now().add(const Duration(days: 7)), isCompleted: false))
                                .then((_) { _taskTitleControllers[e.eventId]!.clear(); _loadTasks(e.eventId); });
                              }},
                            ),
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
