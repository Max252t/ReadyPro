import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:ready_pro/models/user.dart';
import 'package:ready_pro/repositories/auth_repository.dart';
import 'package:ready_pro/core/logger.dart';

class AuthException implements Exception {
  final String message;
  AuthException(this.message);
  @override
  String toString() => message;
}

class SupabaseAuthRepository implements AuthRepository {
  final supabase.SupabaseClient _client;

  SupabaseAuthRepository(this._client);

  static const int _signedUrlTtlSeconds = 60 * 60; // 1 hour

  String? _extractPublicStoragePath({
    required String publicUrl,
    required String bucket,
  }) {
    // Example:
    // https://<project>.supabase.co/storage/v1/object/public/<bucket>/<path>
    final marker = '/storage/v1/object/public/$bucket/';
    final idx = publicUrl.indexOf(marker);
    if (idx == -1) return null;
    return publicUrl.substring(idx + marker.length);
  }

  Future<String?> _maybeCreateSignedAvatarUrl(String? avatarUrl) async {
    if (avatarUrl == null || avatarUrl.isEmpty) return null;
    // If it's already a signed URL (or not a public storage URL), don't touch it.
    if (!avatarUrl.contains('/storage/v1/object/public/profile/')) return avatarUrl;

    final path = _extractPublicStoragePath(
      publicUrl: avatarUrl,
      bucket: 'profile',
    );
    if (path == null || path.isEmpty) return avatarUrl;

    try {
      return await _client.storage.from('profile').createSignedUrl(
            path,
            _signedUrlTtlSeconds,
          );
    } catch (e) {
      // Keep the original URL so the UI can still decide what to do.
      AppLogger.e('CreateSignedUrl (profile) failed', e);
      return avatarUrl;
    }
  }

  void _validatePassword(String password) {
    if (password.length < 6) {
      throw AuthException('Пароль должен содержать не менее 6 символов');
    }
  }

  Future<String?> _uploadDefaultAvatar(String userId) async {
    try {
      final byteData = await rootBundle.load('assets/images/avatar.png');
      final bytes = byteData.buffer.asUint8List();
      final fileName = '$userId/avatar.png';

      await _client.storage.from('profile').uploadBinary(
            fileName,
            bytes,
            fileOptions: const supabase.FileOptions(upsert: true, contentType: 'image/png'),
          );

      return _client.storage.from('profile').getPublicUrl(fileName);
    } catch (e) {
      AppLogger.e('Error uploading default avatar', e);
      return null;
    }
  }

  @override
  Future<String?> updateAvatar(dynamic imageFile) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return null;

      final fileName = '${user.id}/avatar_${DateTime.now().millisecondsSinceEpoch}.png';

      if (kIsWeb) {
        final bytes = await (imageFile as dynamic).readAsBytes();
        await _client.storage.from('profile').uploadBinary(
              fileName,
              bytes,
              fileOptions: const supabase.FileOptions(upsert: true, contentType: 'image/png'),
            );
      } else {
        await _client.storage.from('profile').upload(
              fileName,
              imageFile as File,
              fileOptions: const supabase.FileOptions(upsert: true, contentType: 'image/png'),
            );
      }

      final newUrl = _client.storage.from('profile').getPublicUrl(fileName);
      await _client.from('profiles').update({'avatar_url': newUrl}).eq('id', user.id);

      return newUrl;
    } catch (e) {
      AppLogger.e('Update avatar error', e);
      rethrow;
    }
  }

  @override
  Future<void> updateProfile({required String fullName, String? company}) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) throw AuthException('Пользователь не авторизован');

      await _client.from('profiles').update({
        'full_name': fullName,
        'company': company,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', user.id);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Profile?> signIn({required String email, required String password}) async {
    _validatePassword(password);
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
      if (e is supabase.AuthException) {
        throw AuthException(e.message);
      }
      rethrow;
    }
  }

  @override
  Future<Profile?> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    _validatePassword(password);
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': fullName,
        },
      );

      if (response.user != null) {
        final userId = response.user!.id;
        final avatarUrl = await _uploadDefaultAvatar(userId);
        final signedAvatarUrl = await _maybeCreateSignedAvatarUrl(avatarUrl);
        final now = DateTime.now().toIso8601String();
        
        final profileData = {
          'id': userId,
          'full_name': fullName,
          'email': email,
          'avatar_url': signedAvatarUrl ?? avatarUrl,
          'company': 'Company Name',
          'created_at': now,
          'updated_at': now,
        };

        await _client.from('profiles').upsert(profileData);
        return Profile.fromJson(profileData);
      }
      return null;
    } catch (e) {
      if (e is supabase.AuthException) {
        throw AuthException(e.message);
      }
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
        try {
          return await _getProfile(user.id);
        } catch (_) {
          return null;
        }
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

    final profile = Profile.fromJson(data);
    final signedAvatarUrl = await _maybeCreateSignedAvatarUrl(profile.avatarUrl);
    if (signedAvatarUrl == null || signedAvatarUrl.isEmpty) {
      return profile;
    }

    // Always replace with signed URL when possible.
    if (signedAvatarUrl != profile.avatarUrl) {
      return profile.copyWith(avatarUrl: signedAvatarUrl);
    }
    return profile;
  }
}
