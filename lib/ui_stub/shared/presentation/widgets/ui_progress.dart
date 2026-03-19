import 'package:flutter/material.dart';

class UiProgress extends StatelessWidget {
  final double value; // 0..100

  const UiProgress({super.key, required this.value});

  @override
  Widget build(BuildContext context) {
    final v = (value.clamp(0, 100)) / 100.0;
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: SizedBox(
        height: 10,
        child: LinearProgressIndicator(
          value: v,
          backgroundColor:
              Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.10),
        ),
      ),
    );
  }
}

