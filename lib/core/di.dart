import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ready_pro/repositories/auth_repository.dart';
import 'package:ready_pro/repositories/supabase_auth_repository.dart';
import 'package:ready_pro/repositories/event_repository.dart';
import 'package:ready_pro/repositories/supabase_event_repository.dart';
import 'package:ready_pro/repositories/section_repository.dart';
import 'package:ready_pro/repositories/supabase_section_repository.dart';
import 'package:ready_pro/repositories/talk_repository.dart';
import 'package:ready_pro/repositories/supabase_talk_repository.dart';
import 'package:ready_pro/repositories/task_repository.dart';
import 'package:ready_pro/repositories/supabase_task_repository.dart';
import 'package:ready_pro/repositories/feedback_repository.dart';
import 'package:ready_pro/repositories/supabase_feedback_repository.dart';
import 'package:ready_pro/repositories/schedule_repository.dart';
import 'package:ready_pro/repositories/supabase_schedule_repository.dart';
import 'package:ready_pro/repositories/message_repository.dart';
import 'package:ready_pro/repositories/supabase_message_repository.dart';

final getIt = GetIt.instance;

void setupDI() {
  getIt.registerSingleton<SupabaseClient>(Supabase.instance.client);
  
  getIt.registerLazySingleton<AuthRepository>(
    () => SupabaseAuthRepository(getIt<SupabaseClient>()),
  );

  getIt.registerLazySingleton<EventRepository>(
    () => SupabaseEventRepository(getIt<SupabaseClient>()),
  );

  getIt.registerLazySingleton<SectionRepository>(
    () => SupabaseSectionRepository(getIt<SupabaseClient>()),
  );

  getIt.registerLazySingleton<TalkRepository>(
    () => SupabaseTalkRepository(getIt<SupabaseClient>()),
  );

  getIt.registerLazySingleton<TaskRepository>(
    () => SupabaseTaskRepository(getIt<SupabaseClient>()),
  );

  getIt.registerLazySingleton<FeedbackRepository>(
    () => SupabaseFeedbackRepository(getIt<SupabaseClient>()),
  );

  getIt.registerLazySingleton<ScheduleRepository>(
    () => SupabaseScheduleRepository(getIt<SupabaseClient>()),
  );

  getIt.registerLazySingleton<MessageRepository>(
    () => SupabaseMessageRepository(getIt<SupabaseClient>()),
  );
}
