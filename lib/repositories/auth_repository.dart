import 'package:ready_pro/models/user.dart';

abstract class AuthRepository {
  Future<User?> signIn({required String email, required String password});
  Future<User?> signUp({
    required String email,
    required String password,
    required String fullName,
    required String role,
  });
  Future<void> signOut();
  Future<User?> getCurrentUser();
  Stream<User?> get authStateChanges;
}
