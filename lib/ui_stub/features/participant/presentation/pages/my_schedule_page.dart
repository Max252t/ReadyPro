import 'package:flutter/material.dart';

import '../../../../shared/presentation/widgets/app_scaffold.dart';
import '../../../../shared/presentation/widgets/placeholders.dart';

class MySchedulePage extends StatelessWidget {
  const MySchedulePage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Participant • My schedule (UI stub)',
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          PlaceholderPanel('Сохранённые доклады/слоты (заглушка)'),
          SizedBox(height: 12),
          PlaceholderPanel('Сортировка/фильтры (заглушка)'),
        ],
      ),
    );
  }
}

