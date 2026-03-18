import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ready_pro/models/message.dart';
import 'package:ready_pro/repositories/supabase_message_repository.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}
class MockSupabaseQueryBuilder extends Mock implements SupabaseQueryBuilder {}
class MockPostgrestFilterBuilder extends Mock implements PostgrestFilterBuilder<List<Map<String, dynamic>>> {}
class MockPostgrestTransformBuilder extends Mock implements PostgrestTransformBuilder<List<Map<String, dynamic>>> {}
class MockPostgrestFilterBuilderGeneric extends Mock implements PostgrestFilterBuilder<dynamic> {}

void main() {
  late SupabaseMessageRepository repository;
  late MockSupabaseClient mockClient;
  late MockSupabaseQueryBuilder mockQueryBuilder;
  late MockPostgrestFilterBuilder mockFilterBuilder;
  late MockPostgrestTransformBuilder mockTransformBuilder;

  setUpAll(() {
    registerFallbackValue(const {});
  });

  setUp(() {
    mockClient = MockSupabaseClient();
    mockQueryBuilder = MockSupabaseQueryBuilder();
    mockFilterBuilder = MockPostgrestFilterBuilder();
    mockTransformBuilder = MockPostgrestTransformBuilder();
    repository = SupabaseMessageRepository(mockClient);
  });

  group('SupabaseMessageRepository Tests', () {
    const talkId = 'talk-123';

    test('getMessagesByTalk returns list of messages with profiles', () async {
      final mockData = [
        {
          'id': 'msg-1',
          'talk_id': talkId,
          'user_id': 'user-1',
          'content': 'Hello!',
          'parent_id': null,
          'created_at': DateTime.now().toIso8601String(),
          'profiles': {
            'id': 'user-1',
            'full_name': 'John Doe',
            'email': 'john@test.com',
          }
        }
      ];

      when(() => mockClient.from(any())).thenAnswer((_) => mockQueryBuilder);
      when(() => mockQueryBuilder.select(any())).thenAnswer((_) => mockFilterBuilder);
      when(() => mockFilterBuilder.eq(any(), any())).thenAnswer((_) => mockFilterBuilder);
      when(() => mockFilterBuilder.order(any(), ascending: any(named: 'ascending')))
          .thenAnswer((_) => mockTransformBuilder);

      when(() => mockTransformBuilder.then<dynamic>(any(), onError: any(named: 'onError')))
          .thenAnswer((invocation) {
        final callback = invocation.positionalArguments[0] as Function;
        return Future.value(callback(mockData));
      });

      final messages = await repository.getMessagesByTalk(talkId);

      expect(messages.length, 1);
      expect(messages.first.content, 'Hello!');
      expect(messages.first.user?.fullName, 'John Doe');
    });

    test('sendMessage inserts message correctly', () async {
      final message = Message(
        id: '',
        talkId: talkId,
        userId: 'user-1',
        content: 'New message',
        createdAt: DateTime.now(),
      );

      final insertFilterBuilder = MockPostgrestFilterBuilderGeneric();

      when(() => mockClient.from(any())).thenAnswer((_) => mockQueryBuilder);
      when(() => mockQueryBuilder.insert(any())).thenAnswer((_) => insertFilterBuilder);

      when(() => insertFilterBuilder.then<dynamic>(any(), onError: any(named: 'onError')))
          .thenAnswer((invocation) {
        final callback = invocation.positionalArguments[0] as Function;
        return Future.value(callback({}));
      });

      await repository.sendMessage(message);

      verify(() => mockQueryBuilder.insert({
        'talk_id': message.talkId,
        'user_id': message.userId,
        'content': message.content,
        'parent_id': message.parentId,
      })).called(1);
    });

    test('deleteMessage calls delete on correct id', () async {
      const msgId = 'msg-123';
      final deleteFilterBuilder = MockPostgrestFilterBuilderGeneric();

      when(() => mockClient.from(any())).thenAnswer((_) => mockQueryBuilder);
      when(() => mockQueryBuilder.delete()).thenAnswer((_) => deleteFilterBuilder);
      when(() => deleteFilterBuilder.eq(any(), any())).thenAnswer((_) => deleteFilterBuilder);

      when(() => deleteFilterBuilder.then<dynamic>(any(), onError: any(named: 'onError')))
          .thenAnswer((invocation) {
        final callback = invocation.positionalArguments[0] as Function;
        return Future.value(callback([]));
      });

      await repository.deleteMessage(msgId);

      verify(() => mockQueryBuilder.delete()).called(1);
      verify(() => deleteFilterBuilder.eq('id', msgId)).called(1);
    });
  });
}