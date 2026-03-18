import 'dart:io';
import 'package:ready_pro/models/user.dart';

abstract class AuthRepository {
  Future<Profile?> signIn({required String email, required String password});
  Future<Profile?> signUp({
    required String email,
    required String password,
    required String fullName,
  });
  Future<void> signOut();
  Future<Profile?> getCurrentUser();
  Stream<Profile?> get authStateChanges;
  
  // Новый метод для обновления аватара
  Future<String?> updateAvatar(File imageFile);
}
