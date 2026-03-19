import 'package:flutter/material.dart';

import '../../../../../app/routes.dart';
import '../../../../shared/presentation/widgets/app_scaffold.dart';
import '../../../../shared/presentation/widgets/placeholders.dart';

class SpeakerTalksPage extends StatelessWidget {
  const SpeakerTalksPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Speaker • Talks (UI stub)',
      actions: [
        IconButton(
          onPressed: () => Navigator.pushNamed(context, AppRoutes.profile),
          icon: const Icon(Icons.person_outline),
        ),
      ],
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const PlaceholderPanel('Мои доклады (заглушка)'),
          const SizedBox(height: 12),
          ListTile(
            title: const Text('Talk details (пример)'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.pushNamed(context, AppRoutes.talkDetails),
          ),
        ],
      ),
    );
  }
}

