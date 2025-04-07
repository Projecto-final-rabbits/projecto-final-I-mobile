import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class SignUpSeller {
  final AuthRepository repository;

  SignUpSeller(this.repository);

  Future<Either<Failure, User>> call(SignUpSellerParams params) async {
    return await repository.signUpSeller(
      params.email,
      params.password,
      params.name,
      params.zone,
      params.phone,
    );
  }
}

class SignUpSellerParams extends Equatable {
  final String email;
  final String password;
  final String name;
  final String zone;
  final String phone;

  const SignUpSellerParams({
    required this.email,
    required this.password,
    required this.name,
    required this.zone,
    required this.phone,
  });

  @override
  List<Object> get props => [email, password, name, zone, phone];
}
