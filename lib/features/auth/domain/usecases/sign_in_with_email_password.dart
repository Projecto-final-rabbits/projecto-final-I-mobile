import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class SignInWithEmailPassword {
  final AuthRepository repository;

  SignInWithEmailPassword(this.repository);

  Future<Either<Failure, User>> call(
    SignInWithEmailPasswordParams params,
  ) async {
    return await repository.signInWithEmailAndPassword(
      params.email,
      params.password,
    );
  }
}

class SignInWithEmailPasswordParams extends Equatable {
  final String email;
  final String password;

  const SignInWithEmailPasswordParams({
    required this.email,
    required this.password,
  });

  @override
  List<Object> get props => [email, password];
}
