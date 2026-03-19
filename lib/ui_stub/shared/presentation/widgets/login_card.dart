import 'package:flutter/material.dart';

import '../../../../../../app/theme/app_colors.dart';

class LoginCard extends StatelessWidget {
  final Widget child;
  const LoginCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.loginGradientFrom,
            AppColors.loginGradientTo,
          ],
        ),
      ),
      child: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: child,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

