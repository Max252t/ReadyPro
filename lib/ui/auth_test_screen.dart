import 'package:flutter/material.dart';
import 'package:ready_pro/core/di.dart';
import 'package:ready_pro/repositories/auth_repository.dart';
import 'package:ready_pro/repositories/event_repository.dart';
import 'package:ready_pro/repositories/supabase_auth_repository.dart';
import 'package:ready_pro/models/user.dart';
import 'package:ready_pro/models/user_event.dart';
import 'package:ready_pro/models/event.dart';
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
  
  Profile? _currentUser;
  bool _isLoading = false;
  List<UserEvent> _myEvents = [];

  @override
  void initState() {
    super.initState();
    _checkUser();
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
      if (mounted) {
        setState(() => _myEvents = events);
      }
    } catch (e) {
      print('Ошибка загрузки моих ивентов: $e');
    }
  }

  Future<void> _handleCreateEvent() async {
    if (_currentUser == null) return;
    
    final newEvent = Event(
      id: '',
      title: 'Новое событие ${DateTime.now().second}',
      description: 'Создано из приложения',
      status: EventStatus.preparation,
      createdBy: _currentUser!.id,
      startDate: DateTime.now(),
      endDate: DateTime.now().add(const Duration(days: 1)),
    );

    try {
      await getIt<EventRepository>().createEvent(newEvent);
      _loadMyEvents();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Мероприятие создано!')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ошибка создания: $e')));
    }
  }

  Future<void> _handleSignIn() async {
    setState(() => _isLoading = true);
    try {
      final profile = await getIt<AuthRepository>().signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      if (mounted) {
        setState(() => _currentUser = profile);
        _loadMyEvents();
      }
    } on AuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleSignUp() async {
    setState(() => _isLoading = true);
    try {
      final profile = await getIt<AuthRepository>().signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        fullName: _nameController.text.trim(),
      );
      if (mounted) {
        setState(() => _currentUser = profile);
        _loadMyEvents();
      }
    } on AuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Мои Мероприятия')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                if (_currentUser != null) ...[
                  Text('Профиль: ${_currentUser!.fullName}'),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _handleCreateEvent, 
                    child: const Text('Создать как Организатор'),
                  ),
                  const Divider(),
                  Text('Мероприятия с моим участием (${_myEvents.length}):'),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _myEvents.length,
                      itemBuilder: (context, index) {
                        final e = _myEvents[index];
                        return ListTile(
                          leading: const Icon(Icons.stars, color: Colors.orange),
                          title: Text(e.title),
                          subtitle: Text('Роль: ${e.role.name} | Статус: ${e.status.name}'),
                        );
                      },
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      await getIt<AuthRepository>().signOut();
                      if (mounted) {
                        setState(() {
                          _currentUser = null;
                          _myEvents = [];
                        });
                      }
                    }, 
                    child: const Text('Выйти'),
                  ),
                ] else ...[
                  TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'ФИО')),
                  TextField(controller: _emailController, decoration: const InputDecoration(labelText: 'Email')),
                  TextField(controller: _passwordController, decoration: const InputDecoration(labelText: 'Пароль'), obscureText: true),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(onPressed: _handleSignIn, child: const Text('Войти')),
                      ElevatedButton(onPressed: _handleSignUp, child: const Text('Регистрация')),
                    ],
                  ),
                ],
              ],
            ),
      ),
    );
  }
}
