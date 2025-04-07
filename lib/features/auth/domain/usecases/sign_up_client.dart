import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class SignUpClient {
  final AuthRepository repository;

  SignUpClient(this.repository);

  Future<Either<Failure, User>> call(SignUpClientParams params) async {
    return await repository.signUpClient(
      params.email,
      params.password,
      params.name,
      params.clientType,
      params.address,
      params.phone,
    );
  }
}

class SignUpClientParams extends Equatable {
  final String email;
  final String password;
  final String name;
  final String clientType;
  final String address;
  final String phone;

  const SignUpClientParams({
    required this.email,
    required this.password,
    required this.name,
    required this.clientType,
    required this.address,
    required this.phone,
  });

  @override
  List<Object> get props => [email, password, name, clientType, address, phone];
}
