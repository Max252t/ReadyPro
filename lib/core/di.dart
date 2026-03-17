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
}
