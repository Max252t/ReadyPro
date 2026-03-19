import 'package:flutter/material.dart';

/// Управление светлой / тёмной темой для всего приложения.
class AppThemeController extends ChangeNotifier {
  AppThemeController({ThemeMode initial = ThemeMode.light}) : _mode = initial;

  ThemeMode _mode;

  ThemeMode get mode => _mode;

  /// Переключение только light ↔ dark (как в веб-макете).
  void toggleLightDark() {
    _mode = _mode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
  }
}

class AppThemeScope extends InheritedNotifier<AppThemeController> {
  const AppThemeScope({
    super.key,
    required AppThemeController super.notifier,
    required super.child,
  });

  static AppThemeController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppThemeScope>();
    assert(scope != null, 'AppThemeScope: оберните MaterialApp.builder');
    return scope!.notifier!;
  }
}
