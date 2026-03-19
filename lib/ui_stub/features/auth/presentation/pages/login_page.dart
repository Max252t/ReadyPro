import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../app/routes.dart';
import '../../../../../app/widgets/theme_toggle_button.dart';
import '../../../../../blocs/auth/auth_bloc.dart';
import '../../../../../blocs/auth/auth_event.dart';
import '../../../../../blocs/auth/auth_state.dart';
import '../../../../../blocs/event/event_bloc.dart';
import '../../../../../blocs/event/event_event.dart';
import '../../../../shared/presentation/widgets/login_card.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          // После входа загружаем мероприятия пользователя
          context.read<EventBloc>().add(LoadMyEvents(state.user.id));
          
          // Для простоты MVP перенаправляем на программу. 
          // В идеале здесь должен быть экран выбора мероприятия.
          Navigator.pushReplacementNamed(context, AppRoutes.participantProgram);
        } else if (state is AuthFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: Scaffold(
        body: Stack(
          children: [
            LoginCard(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'ReadyPro',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Система управления мероприятиями',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withValues(
                                alpha: 0.65,
                              ),
                        ),
                  ),
                  const SizedBox(height: 20),
                  const Text('Email'),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      hintText: 'ваш@email.com',
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text('Пароль'),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      hintText: '••••••••',
                    ),
                  ),
                  const SizedBox(height: 16),
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      if (state is AuthLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      return FilledButton(
                        onPressed: () {
                          context.read<AuthBloc>().add(
                                AuthSignInRequested(
                                  _emailController.text.trim(),
                                  _passwordController.text.trim(),
                                ),
                              );
                        },
                        child: const Text('Войти'),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SafeArea(
              child: Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: ThemeToggleButton(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
