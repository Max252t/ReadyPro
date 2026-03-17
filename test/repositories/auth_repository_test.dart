import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:ready_pro/repositories/supabase_auth_repository.dart';

class MockSupabaseClient extends Mock implements supabase.SupabaseClient {}
class MockGoTrueClient extends Mock implements supabase.GoTrueClient {}
class MockSupabaseQueryBuilder extends Mock implements supabase.SupabaseQueryBuilder {}
class MockPostgrestFilterBuilder extends Mock 
    implements supabase.PostgrestFilterBuilder<List<Map<String, dynamic>>> {}
class MockPostgrestTransformBuilder extends Mock 
    implements supabase.PostgrestTransformBuilder<Map<String, dynamic>> {}

void main() {
  late SupabaseAuthRepository repository;
  late MockSupabaseClient mockClient;
  late MockGoTrueClient mockAuth;

  setUpAll(() {
    registerFallbackValue((Map<String, dynamic> _) async => {});
  });

  setUp(() {
    mockClient = MockSupabaseClient();
    mockAuth = MockGoTrueClient();
    when(() => mockClient.auth).thenReturn(mockAuth);
    repository = SupabaseAuthRepository(mockClient);
  });

  group('SupabaseAuthRepository Validation Tests', () {
    test('signIn should throw AuthException if password is too short', () async {
      expect(
        () => repository.signIn(email: 'test@test.com', password: '123'),
        throwsA(isA<AuthException>()),
      );
    });

    test('signUp should throw AuthException if password is too short', () async {
      expect(
        () => repository.signUp(
          email: 'test@test.com', 
          password: '123', 
          fullName: 'Test User'
        ),
        throwsA(isA<AuthException>()),
      );
    });
  });

  group('SupabaseAuthRepository Logic Tests', () {
    test('signIn calls Supabase auth and returns profile', () async {
      final response = supabase.AuthResponse(
        user: supabase.User(
          id: '123',
          appMetadata: {},
          userMetadata: {},
          aud: '',
          createdAt: '',
        ),
      );

      when(() => mockAuth.signInWithPassword(
        email: 'test@test.com',
        password: 'password123',
      )).thenAnswer((_) async => response);

      final queryBuilder = MockSupabaseQueryBuilder();
      final filterBuilder = MockPostgrestFilterBuilder();
      final transformBuilder = MockPostgrestTransformBuilder();
      
      when(() => mockClient.from(any())).thenAnswer((_) => queryBuilder);
      when(() => queryBuilder.select()).thenAnswer((_) => filterBuilder);
      when(() => filterBuilder.eq(any(), any())).thenAnswer((_) => filterBuilder);
      when(() => filterBuilder.single()).thenAnswer((_) => transformBuilder);

      when(() => transformBuilder.then<dynamic>(any(), onError: any(named: 'onError')))
          .thenAnswer((invocation) {
        final callback = invocation.positionalArguments[0] as Function;
        return Future.value(callback({
          'id': '123',
          'full_name': 'Test User',
          'email': 'test@test.com',
          'created_at': DateTime.now().toIso8601String(),
        }));
      });

      final result = await repository.signIn(
        email: 'test@test.com',
        password: 'password123',
      );

      expect(result?.id, '123');
      expect(result?.fullName, 'Test User');
      verify(() => mockAuth.signInWithPassword(
        email: 'test@test.com',
        password: 'password123',
      )).called(1);
    });
  });
}
