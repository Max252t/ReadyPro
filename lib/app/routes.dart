import 'package:flutter/material.dart';

import '../ui_stub/features/auth/presentation/pages/login_page.dart';
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

class AppRoutes {
  static const login = '/login';
  static const profile = '/profile';

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

  static Map<String, WidgetBuilder> get map => {
        login: (_) => const LoginPage(),
        profile: (_) => const ProfilePage(),
        curatorDashboard: (_) => const CuratorDashboardPage(),
        curatorReports: (_) => const CuratorReportsPage(),
        organizerDashboard: (_) => const OrganizerDashboardPage(),
        organizerSchedule: (_) => const SchedulePage(),
        organizerSections: (_) => const SectionsPage(),
        organizerTasks: (_) => const TasksPage(),
        participantProgram: (_) => const ProgramPage(),
        participantMySchedule: (_) => const MySchedulePage(),
        speakerTalks: (_) => const SpeakerTalksPage(),
        talkDetails: (_) => const TalkDetailsPage(),
      };
}

