import 'package:flutter/material.dart';

import 'routes.dart';
import 'theme/app_theme.dart';

class ReadyProApp extends StatelessWidget {
  const ReadyProApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ReadyPro',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      initialRoute: AppRoutes.login,
      routes: AppRoutes.map,
    );
  }
}

