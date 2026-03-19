import 'package:flutter/material.dart';

class AppScaffold extends StatelessWidget {
  final String title;
  final Widget child;
  final List<Widget>? actions;
  final Widget? bottomNavigation;

  const AppScaffold({
    super.key,
    required this.title,
    required this.child,
    this.actions,
    this.bottomNavigation,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: actions,
      ),
      body: SafeArea(child: child),
      bottomNavigationBar: bottomNavigation,
    );
  }
}

