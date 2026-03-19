import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ready_pro/core/di.dart';
import 'package:ready_pro/ui/auth_test_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://ncxuwvxngipgkevvbnrc.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5jeHV3dnhuZ2lwZ2tldnZibnJjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzM2NjM3NjYsImV4cCI6MjA4OTIzOTc2Nn0.9zZ71UP4gvh0NWQ6aoh2ysbbfw5MaO6EkUJfw4qAY88',
  );

  setupDI();

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ГотовностьПро Тест',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const AuthTestScreen(),
    );
  }
}

