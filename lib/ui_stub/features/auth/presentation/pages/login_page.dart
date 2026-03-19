import 'package:flutter/material.dart';

import '../../../../../app/routes.dart';
import '../../../../../app/widgets/theme_toggle_button.dart';
import '../../../../shared/mock/ui_models.dart';
import '../../../../shared/presentation/widgets/login_card.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          LoginCard(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Хакатон 2026',
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
                const TextField(
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: 'ваш@email.com',
                  ),
                ),
                const SizedBox(height: 12),
                const Text('Пароль'),
                const SizedBox(height: 6),
                const TextField(
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: '••••••••',
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () => Navigator.pushNamed(
                    context,
                    AppRoutes.organizerDashboard,
                    arguments: const {'role': UiRole.organizer},
                  ),
                  child: const Text('Войти (заглушка)'),
                ),
                const SizedBox(height: 18),
                Text(
                  'Быстрый вход (демо):',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withValues(
                              alpha: 0.55,
                            ),
                      ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  alignment: WrapAlignment.center,
                  children: [
                    OutlinedButton(
                      onPressed: () => Navigator.pushNamed(
                        context,
                        AppRoutes.organizerDashboard,
                        arguments: const {'role': UiRole.organizer},
                      ),
                      child: const Text('Организатор'),
                    ),
                    OutlinedButton(
                      onPressed: () => Navigator.pushNamed(
                        context,
                        AppRoutes.curatorDashboard,
                        arguments: const {'role': UiRole.curator},
                      ),
                      child: const Text('Куратор'),
                    ),
                    OutlinedButton(
                      onPressed: () => Navigator.pushNamed(
                        context,
                        AppRoutes.speakerTalks,
                        arguments: const {'role': UiRole.speaker},
                      ),
                      child: const Text('Спикер'),
                    ),
                    OutlinedButton(
                      onPressed: () => Navigator.pushNamed(
                        context,
                        AppRoutes.participantProgram,
                        arguments: const {'role': UiRole.participant},
                      ),
                      child: const Text('Участник'),
                    ),
                  ],
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
    );
  }
}

