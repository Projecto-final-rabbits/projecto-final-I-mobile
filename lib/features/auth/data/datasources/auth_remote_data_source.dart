import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  /// Sign in with email and password
  Future<UserModel> signInWithEmailAndPassword(String email, String password);

  /// Sign up with email and password
  Future<UserModel> signUpWithEmailAndPassword(
    String email,
    String password,
    String name,
  );

  /// Sign out the current user
  Future<void> signOut();

  /// Get the current authenticated user if any
  Future<UserModel?> getCurrentUser();
}
