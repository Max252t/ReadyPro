import 'package:flutter/material.dart';

import '../../../../../app/routes.dart';
import '../../../../shared/presentation/widgets/app_scaffold.dart';
import '../../../../shared/presentation/widgets/placeholders.dart';

class ProgramPage extends StatelessWidget {
  const ProgramPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Participant • Program (UI stub)',
      actions: [
        IconButton(
          onPressed: () => Navigator.pushNamed(context, AppRoutes.profile),
          icon: const Icon(Icons.person_outline),
        ),
      ],
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const PlaceholderPanel('Программа мероприятия (заглушка)'),
          const SizedBox(height: 12),
          ListTile(
            title: const Text('Моё расписание'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.pushNamed(context, AppRoutes.participantMySchedule),
          ),
          ListTile(
            title: const Text('Открыть доклад (пример)'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.pushNamed(context, AppRoutes.talkDetails),
          ),
        ],
      ),
    );
  }
}

