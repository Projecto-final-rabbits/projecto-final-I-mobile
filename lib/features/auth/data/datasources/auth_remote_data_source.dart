import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  /// Sign in with email and password
  Future<UserModel> signInWithEmailAndPassword(String email, String password);

  /// Sign up client with email and password
  Future<UserModel> signUpClient(
    String email,
    String password,
    String name,
    String clientType,
    String address,
    String phone,
  );

  /// Sign up seller with email and password
  Future<UserModel> signUpSeller(
    String email,
    String password,
    String name,
    String zone,
    String phone,
  );

  /// Sign out the current user
  Future<void> signOut();

  /// Get the current authenticated user if any
  Future<UserModel?> getCurrentUser();
}
