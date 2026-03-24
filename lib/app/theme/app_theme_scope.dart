import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Управление светлой / тёмной темой для всего приложения.
class AppThemeController extends ChangeNotifier {
  static const _themeKey = 'theme_mode';
  final SharedPreferences _prefs;
  ThemeMode _mode;

  AppThemeController(this._prefs)
      : _mode = _loadThemeMode(_prefs);

  ThemeMode get mode => _mode;

  static ThemeMode _loadThemeMode(SharedPreferences prefs) {
    final savedMode = prefs.getString(_themeKey);
    if (savedMode == 'dark') return ThemeMode.dark;
    if (savedMode == 'light') return ThemeMode.light;
    return ThemeMode.system;
  }

  /// Переключение только light ↔ dark (как в веб-макете).
  Future<void> toggleLightDark() async {
    _mode = _mode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    await _prefs.setString(_themeKey, _mode == ThemeMode.dark ? 'dark' : 'light');
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
