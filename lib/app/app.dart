import 'package:flutter/material.dart';

import 'routes.dart';
import 'theme/app_theme.dart';
import 'theme/app_theme_scope.dart';

class ReadyProApp extends StatefulWidget {
  const ReadyProApp({super.key});

  @override
  State<ReadyProApp> createState() => _ReadyProAppState();
}

class _ReadyProAppState extends State<ReadyProApp> {
  late final AppThemeController _themeController;

  @override
  void initState() {
    super.initState();
    _themeController = AppThemeController();
  }

  @override
  void dispose() {
    _themeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _themeController,
      builder: (context, _) {
        return MaterialApp(
          title: 'ReadyPro',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: _themeController.mode,
          builder: (context, child) {
            return AppThemeScope(
              notifier: _themeController,
              child: child ?? const SizedBox.shrink(),
            );
          },
          initialRoute: AppRoutes.login,
          routes: AppRoutes.map,
        );
      },
    );
  }
}

