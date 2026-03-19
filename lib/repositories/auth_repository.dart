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
  
  // Метод для обновления аватара (dynamic для поддержки File и XFile)
  Future<String?> updateAvatar(dynamic imageFile);

  // Метод для обновления данных профиля
  Future<void> updateProfile({required String fullName, String? company});
}
