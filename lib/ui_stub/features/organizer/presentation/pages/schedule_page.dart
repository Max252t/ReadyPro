import 'package:flutter/material.dart';

import '../../../../shared/presentation/widgets/app_scaffold.dart';
import '../../../../shared/presentation/widgets/placeholders.dart';

class SchedulePage extends StatelessWidget {
  const SchedulePage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Organizer • Schedule (UI stub)',
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          PlaceholderPanel('Список слотов/докладов (заглушка)'),
          SizedBox(height: 12),
          PlaceholderPanel('Фильтры/поиск (заглушка)'),
        ],
      ),
    );
  }
}

