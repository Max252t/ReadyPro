import 'package:flutter/material.dart';

class UiBadge extends StatelessWidget {
  final String text;
  final UiBadgeVariant variant;

  const UiBadge(
    this.text, {
    super.key,
    this.variant = UiBadgeVariant.outline,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    Color bg;
    Color fg;
    BorderSide border;

    switch (variant) {
      case UiBadgeVariant.defaultFill:
        bg = scheme.primary;
        fg = scheme.onPrimary;
        border = BorderSide(color: scheme.primary);
        break;
      case UiBadgeVariant.secondary:
        bg = scheme.primary.withValues(alpha: 0.10);
        fg = scheme.primary;
        border = BorderSide(color: scheme.primary.withValues(alpha: 0.20));
        break;
      case UiBadgeVariant.outline:
        bg = Colors.transparent;
        fg = scheme.onSurface.withValues(alpha: 0.8);
        border = BorderSide(color: Theme.of(context).dividerColor);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        border: Border.all(color: border.color),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: fg,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}

enum UiBadgeVariant { outline, defaultFill, secondary }

