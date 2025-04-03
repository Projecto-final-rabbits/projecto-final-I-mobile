import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class SignUpWithEmailPassword {
  final AuthRepository repository;

  SignUpWithEmailPassword(this.repository);

  Future<Either<Failure, User>> call(
    SignUpWithEmailPasswordParams params,
  ) async {
    return await repository.signUpWithEmailAndPassword(
      params.email,
      params.password,
      params.name,
    );
  }
}

class SignUpWithEmailPasswordParams extends Equatable {
  final String email;
  final String password;
  final String name;

  const SignUpWithEmailPasswordParams({
    required this.email,
    required this.password,
    required this.name,
  });

  @override
  List<Object> get props => [email, password, name];
}
