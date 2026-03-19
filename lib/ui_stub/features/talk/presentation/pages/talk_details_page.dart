import 'package:flutter/material.dart';

import '../../../../shared/presentation/widgets/app_scaffold.dart';
import '../../../../shared/presentation/widgets/placeholders.dart';

class TalkDetailsPage extends StatelessWidget {
  const TalkDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Talk details (UI stub)',
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          PlaceholderPanel('Обложка/название/спикер (заглушка)'),
          SizedBox(height: 12),
          PlaceholderPanel('Описание/тайминг/секция (заглушка)'),
          SizedBox(height: 12),
          PlaceholderPanel('Кнопки: добавить в расписание / отзыв (заглушка)'),
        ],
      ),
    );
  }
}

