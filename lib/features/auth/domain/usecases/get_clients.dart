import 'package:dartz/dartz.dart' as dartz;

import '../../../../core/error/failures.dart';
import '../entities/user.dart';
import '../repositories/client_repository.dart';

class GetClients {
  final ClientRepository repository;

  GetClients(this.repository);

  Future<dartz.Either<Failure, List<User>>> call() async {
    return await repository.getClients();
  }
}
