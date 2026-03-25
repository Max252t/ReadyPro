import 'package:flutter/material.dart';

class AppColors {
  // Synced with `figma-export/src/styles/theme.css` (light theme tokens).
  static const background = Color(0xFFFFFFFF); // --background
  static const foreground = Color(0xFF0F172A); // --foreground
  static const card = Color(0xFFFFFFFF); // --card
  static const muted = Color(0xFFF1F5F9); // --muted
  static const mutedForeground = Color(0xFF64748B); // --muted-foreground
  static const primary = Color(0xFF1E40AF); // --primary
  static const primaryForeground = Color(0xFFFFFFFF); // --primary-foreground
  static const accent = Color(0xFFDBEAFE); // --accent
  static const accentForeground = Color(0xFF1E40AF); // --accent-foreground
  static const border = Color(0xFFE2E8F0); // --border
  static const inputBackground = Color(0xFFF8FAFC); // --input-background

  // Login gradient (from `LoginPage.tsx`: from-blue-50 to-indigo-100)
  static const loginGradientFrom = Color(0xFFEFF6FF); // blue-50
  static const loginGradientTo = Color(0xFFE0E7FF); // indigo-100

  /// Токены тёмной темы (как `figma-export` `.dark`).
  static const darkBackground = Color(0xFF1E293B); // Изменено с 0xFF0F172A на более светлый Slate 800
  static const darkForeground = Color(0xFFF1F5F9);
  static const darkCard = Color(0xFF334155); // Изменено с 0xFF1E293B на Slate 700
  static const darkMuted = Color(0xFF475569);
  static const darkMutedForeground = Color(0xFF94A3B8);
  static const darkPrimary = Color(0xFF60A5FA);
  static const darkPrimaryForeground = Color(0xFF0F172A);
  static const darkBorder = Color(0xFF475569);
  static const darkInputBackground = Color(0xFF334155);

  static const loginGradientFromDark = Color(0xFF1E293B);
  static const loginGradientToDark = Color(0xFF334155);
}
