import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  /// Sign in with email and password
  Future<Either<Failure, User>> signInWithEmailAndPassword(
    String email,
    String password,
  );

  /// Sign up with email and password for client
  Future<Either<Failure, User>> signUpClient(
    String email,
    String password,
    String name,
    String clientType,
    String address,
    String phone,
  );

  /// Sign up with email and password for seller
  Future<Either<Failure, User>> signUpSeller(
    String email,
    String password,
    String name,
    String zone,
    String phone,
  );

  /// Sign out the current user
  Future<Either<Failure, void>> signOut();

  /// Get the current authenticated user if any
  Future<Either<Failure, User?>> getCurrentUser();
}
