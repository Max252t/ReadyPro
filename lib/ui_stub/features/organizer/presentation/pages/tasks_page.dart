import 'package:flutter/material.dart';

import '../../../../shared/presentation/widgets/app_scaffold.dart';
import '../../../../shared/presentation/widgets/placeholders.dart';

class TasksPage extends StatelessWidget {
  const TasksPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Organizer • Tasks (UI stub)',
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          PlaceholderPanel('Список задач (заглушка)'),
          SizedBox(height: 12),
          PlaceholderPanel('Форма создания/назначения (заглушка)'),
        ],
      ),
    );
  }
}

