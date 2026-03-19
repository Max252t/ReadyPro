import 'package:flutter/material.dart';

import '../../../../../app/routes.dart';
import '../../../../shared/presentation/widgets/app_scaffold.dart';
import '../../../../shared/presentation/widgets/placeholders.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Profile (UI stub)',
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const PlaceholderPanel('Аватар + имя + роли (заглушка)'),
          const SizedBox(height: 12),
          const PlaceholderPanel('Настройки профиля (заглушка)'),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: () => Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.login,
              (route) => false,
            ),
            child: const Text('Выйти (заглушка)'),
          ),
        ],
      ),
    );
  }
}

