import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:ready_pro/models/user.dart';
import 'package:ready_pro/repositories/auth_repository.dart';

class SupabaseAuthRepository implements AuthRepository {
  final supabase.SupabaseClient _client;

  SupabaseAuthRepository(this._client);

  @override
  Future<Profile?> signIn({required String email, required String password}) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      
      if (response.user != null) {
        return await _getProfile(response.user!.id);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Profile?> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': fullName,
        },
      );

      if (response.user != null) {
        final now = DateTime.now().toIso8601String();
        
        final profileData = {
          'id': response.user!.id,
          'full_name': fullName,
          'email': email,
          'avatar_url': 'assets/images/avatar.png',
          'company': 'Company Name',
          'updated_at': now,
        };

        await _client.from('profiles').upsert(profileData);
        return Profile.fromJson(profileData);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  @override
  Future<Profile?> getCurrentUser() async {
    final user = _client.auth.currentUser;
    if (user != null) {
      return await _getProfile(user.id);
    }
    return null;
  }

  @override
  Stream<Profile?> get authStateChanges {
    return _client.auth.onAuthStateChange.asyncMap((event) async {
      final user = event.session?.user;
      if (user != null) {
        return await _getProfile(user.id);
      }
      return null;
    });
  }

  Future<Profile?> _getProfile(String id) async {
    final data = await _client
        .from('profiles')
        .select()
        .eq('id', id)
        .single();
    return Profile.fromJson(data);
  }
}
