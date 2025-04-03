import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  /// Sign in with email and password
  Future<Either<Failure, User>> signInWithEmailAndPassword(
    String email,
    String password,
  );

  /// Sign up with email and password
  Future<Either<Failure, User>> signUpWithEmailAndPassword(
    String email,
    String password,
    String name,
  );

  /// Sign in with Google
  Future<Either<Failure, User>> signInWithGoogle();

  /// Sign out the current user
  Future<Either<Failure, void>> signOut();

  /// Get the current authenticated user if any
  Future<Either<Failure, User?>> getCurrentUser();
}
