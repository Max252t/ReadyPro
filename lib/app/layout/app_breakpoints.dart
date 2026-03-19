import 'package:flutter/material.dart';

/// Window and layout breakpoints shared across the app.
abstract final class AppBreakpoints {
  /// Phone vs larger layouts (Material window size class).
  static const double compact = 600;

  /// Persistent side navigation vs drawer + app bar.
  static const double expanded = 900;

  /// Cap main content width on very wide viewports.
  static const double contentMaxWidth = 1200;

  /// Organizer dashboard: stat cards row (1 → 2 → 4 columns).
  static const double statsMedium = 700;
  static const double statsWide = 1100;

  /// Organizer sections grid (1 → 2 → 3 columns).
  static const double sectionsTwoCols = 750;
  static const double sectionsThreeCols = 1100;

  /// In-card mini grid (e.g. curator reports stats).
  static const double cardNarrowTwoCols = 520;

  static double windowWidth(BuildContext context) =>
      MediaQuery.sizeOf(context).width;

  static bool isCompact(BuildContext context) =>
      windowWidth(context) < compact;

  static bool isExpanded(BuildContext context) =>
      windowWidth(context) >= expanded;

  static int organizerStatColumns(double maxWidth) {
    if (maxWidth >= statsWide) return 4;
    if (maxWidth >= statsMedium) return 2;
    return 1;
  }

  static int twoColumnCards(double maxWidth) =>
      maxWidth >= expanded ? 2 : 1;

  static int curatorStatColumns(double maxWidth) =>
      maxWidth >= expanded ? 3 : 1;

  static int speakerTalkColumns(double maxWidth) =>
      maxWidth >= expanded ? 2 : 1;

  static int sectionCardColumns(double maxWidth) {
    if (maxWidth >= sectionsThreeCols) return 3;
    if (maxWidth >= sectionsTwoCols) return 2;
    return 1;
  }

  static int taskBoardColumns(double maxWidth) => twoColumnCards(maxWidth);

  static int miniStatColumns(double maxWidth) =>
      maxWidth >= cardNarrowTwoCols ? 2 : 1;
}
