import 'package:flutter/material.dart';

import '../ui_stub/shared/mock/ui_models.dart';
import '../ui_stub/features/auth/presentation/pages/login_page.dart';
import '../ui_stub/features/auth/presentation/pages/register_page.dart';
import '../ui_stub/features/profile/presentation/pages/profile_page.dart';
import '../ui_stub/features/curator/presentation/pages/curator_dashboard_page.dart';
import '../ui_stub/features/curator/presentation/pages/curator_reports_page.dart';
import '../ui_stub/features/organizer/presentation/pages/organizer_dashboard_page.dart';
import '../ui_stub/features/organizer/presentation/pages/schedule_page.dart';
import '../ui_stub/features/organizer/presentation/pages/sections_page.dart';
import '../ui_stub/features/organizer/presentation/pages/tasks_page.dart';
import '../ui_stub/features/participant/presentation/pages/program_page.dart';
import '../ui_stub/features/participant/presentation/pages/my_schedule_page.dart';
import '../ui_stub/features/speaker/presentation/pages/speaker_talks_page.dart';
import '../ui_stub/features/talk/presentation/pages/talk_details_page.dart';
import '../ui_stub/features/participant/presentation/pages/event_details_page.dart';
import '../ui_stub/features/participant/presentation/pages/all_events_page.dart';
import '../ui_stub/shared/route_args.dart';
import '../ui/auth_test_screen.dart';

class AppRoutes {
  static const login = '/login';
  static const register = '/register';
  static const profile = '/profile';
  static const debug = '/debug';
  static const allEvents = '/all-events';

  static const curatorDashboard = '/curator/dashboard';
  static const curatorReports = '/curator/reports';

  static const organizerDashboard = '/organizer/dashboard';
  static const organizerSchedule = '/organizer/schedule';
  static const organizerSections = '/organizer/sections';
  static const organizerTasks = '/organizer/tasks';

  static const participantProgram = '/participant/program';
  static const participantMySchedule = '/participant/my-schedule';

  static const speakerTalks = '/speaker/talks';

  static const talkDetails = '/talk/details';
  static const eventDetails = '/event/details';

  /// Корневой экран роли (после входа), без вложенного стека.
  static String homeRouteForRole(UiRole role) {
    return allEvents;
  }

  static void navigateToRoleHome(
    BuildContext context,
    UiRole role, {
    String? eventId,
  }) {
    final args = <String, dynamic>{'role': role};
    if (eventId != null && eventId.isNotEmpty) {
      args['eventId'] = eventId;
    }
    Navigator.of(context).pushNamedAndRemoveUntil(
      homeRouteForRole(role),
      (_) => false,
      arguments: args,
    );
  }

  static Map<String, WidgetBuilder> get map => {
        login: (_) => const LoginPage(),
        register: (_) => const RegisterPage(),
        profile: (context) => ProfilePage(
              role: uiRoleFromArgs(ModalRoute.of(context)?.settings.arguments),
            ),
        debug: (_) => const AuthTestScreen(),
        allEvents: (context) => AllEventsPage(
              role: uiRoleFromArgs(ModalRoute.of(context)?.settings.arguments),
            ),
        curatorDashboard: (_) => const CuratorDashboardPage(),
        curatorReports: (_) => const CuratorReportsPage(),
        organizerDashboard: (_) => const OrganizerDashboardPage(),
        organizerSchedule: (_) => const SchedulePage(),
        organizerSections: (_) => const SectionsPage(),
        organizerTasks: (_) => const TasksPage(),
        participantProgram: (context) => ProgramPage(
              role: uiRoleFromArgs(ModalRoute.of(context)?.settings.arguments),
            ),
        participantMySchedule: (context) => MySchedulePage(
              role: uiRoleFromArgs(ModalRoute.of(context)?.settings.arguments),
            ),
        speakerTalks: (context) => SpeakerTalksPage(
              role: uiRoleFromArgs(
                ModalRoute.of(context)?.settings.arguments,
                fallback: UiRole.speaker,
              ),
            ),
        talkDetails: (context) => TalkDetailsPage(
              role: uiRoleFromArgs(ModalRoute.of(context)?.settings.arguments),
              talkId: talkIdFromArgs(ModalRoute.of(context)?.settings.arguments) ?? '',
            ),
        eventDetails: (context) => EventDetailsPage(
              eventId: eventIdFromArgs(ModalRoute.of(context)?.settings.arguments) ?? '',
              role: uiRoleFromArgs(ModalRoute.of(context)?.settings.arguments),
            ),
      };
}
