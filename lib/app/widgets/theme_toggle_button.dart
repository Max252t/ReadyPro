import 'package:flutter/material.dart';

import '../theme/app_theme_scope.dart';

/// Кнопка переключения светлой / тёмной темы.
class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({super.key, this.iconSize = 22});

  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return IconButton.filledTonal(
      style: IconButton.styleFrom(
        visualDensity: VisualDensity.compact,
      ),
      tooltip: dark ? 'Светлая тема' : 'Тёмная тема',
      onPressed: () => AppThemeScope.of(context).toggleLightDark(),
      icon: Icon(
        dark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
        size: iconSize,
      ),
    );
  }
}
