import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ready_pro/blocs/auth/auth_bloc.dart';
import 'package:ready_pro/blocs/auth/auth_event.dart';
import 'package:ready_pro/blocs/auth/auth_state.dart';
import 'package:ready_pro/blocs/event/event_bloc.dart';
import 'package:ready_pro/blocs/program/program_bloc.dart';
import 'package:ready_pro/blocs/talk/talk_bloc.dart';
import 'package:ready_pro/blocs/organizer/organizer_bloc.dart';
import 'package:ready_pro/blocs/curator/curator_bloc.dart';
import 'package:ready_pro/core/di.dart';
import 'package:ready_pro/repositories/auth_repository.dart';
import 'package:ready_pro/repositories/event_repository.dart';
import 'package:ready_pro/repositories/section_repository.dart';
import 'package:ready_pro/repositories/talk_repository.dart';
import 'package:ready_pro/repositories/task_repository.dart';
import 'package:ready_pro/repositories/schedule_repository.dart';
import 'package:ready_pro/repositories/message_repository.dart';
import 'package:ready_pro/repositories/feedback_repository.dart';

import 'routes.dart';
import 'theme/app_theme.dart';
import 'theme/app_theme_scope.dart';

class ReadyProApp extends StatefulWidget {
  const ReadyProApp({super.key});

  @override
  State<ReadyProApp> createState() => _ReadyProAppState();
}

class _ReadyProAppState extends State<ReadyProApp> {
  late final AppThemeController _themeController;

  @override
  void initState() {
    super.initState();
    _themeController = AppThemeController();
  }

  @override
  void dispose() {
    _themeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => AuthBloc(getIt<AuthRepository>())..add(AuthCheckRequested()),
        ),
        BlocProvider(
          create: (context) => EventBloc(getIt<EventRepository>()),
        ),
        BlocProvider(
          create: (context) => ProgramBloc(
            sectionRepository: getIt<SectionRepository>(),
            talkRepository: getIt<TalkRepository>(),
            scheduleRepository: getIt<ScheduleRepository>(),
            authRepository: getIt<AuthRepository>(),
          ),
        ),
        BlocProvider(
          create: (context) => TalkBloc(
            talkRepository: getIt<TalkRepository>(),
            sectionRepository: getIt<SectionRepository>(),
            authRepository: getIt<AuthRepository>(),
            messageRepository: getIt<MessageRepository>(),
            feedbackRepository: getIt<FeedbackRepository>(),
          ),
        ),
        BlocProvider(
          create: (context) => OrganizerBloc(
            eventRepository: getIt<EventRepository>(),
            sectionRepository: getIt<SectionRepository>(),
            taskRepository: getIt<TaskRepository>(),
            talkRepository: getIt<TalkRepository>(),
          ),
        ),
        BlocProvider(
          create: (context) => CuratorBloc(
            sectionRepository: getIt<SectionRepository>(),
            talkRepository: getIt<TalkRepository>(),
          ),
        ),
      ],
      child: ListenableBuilder(
        listenable: _themeController,
        builder: (context, _) {
          return MaterialApp(
            title: 'ReadyPro',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: _themeController.mode,
            builder: (context, child) {
              return BlocListener<AuthBloc, AuthState>(
                listener: (context, state) {
                  if (state is AuthUnauthenticated) {
                    Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
                  }
                },
                child: AppThemeScope(
                  notifier: _themeController,
                  child: child ?? const SizedBox.shrink(),
                ),
              );
            },
            initialRoute: AppRoutes.login,
            routes: AppRoutes.map,
          );
        },
      ),
    );
  }
}
