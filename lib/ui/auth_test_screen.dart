import 'package:flutter/material.dart';
import 'package:ready_pro/core/di.dart';
import 'package:ready_pro/repositories/auth_repository.dart';
import 'package:ready_pro/repositories/supabase_auth_repository.dart';
import 'package:ready_pro/models/user.dart';

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

  @override
  void initState() {
    super.initState();
    _checkUser();
  }

  Future<void> _checkUser() async {
    final user = await getIt<AuthRepository>().getCurrentUser();
    setState(() => _currentUser = user);
  }

  Future<void> _handleSignIn() async {
    setState(() => _isLoading = true);
    try {
      final profile = await getIt<AuthRepository>().signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      setState(() => _currentUser = profile);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Успешный вход')));
    } on AuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ошибка: $e')));
    } finally {
      setState(() => _isLoading = false);
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
      setState(() => _currentUser = profile);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Регистрация успешна')));
    } on AuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ошибка: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleSignOut() async {
    await getIt<AuthRepository>().signOut();
    setState(() => _currentUser = null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Тест Авторизации')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                if (_currentUser != null) ...[
                  Text('Вы вошли как: ${_currentUser!.fullName}'),
                  Text('Email: ${_currentUser!.email}'),
                  const SizedBox(height: 20),
                  ElevatedButton(onPressed: _handleSignOut, child: const Text('Выйти')),
                ] else ...[
                  TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'ФИО (для регистрации)')),
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
