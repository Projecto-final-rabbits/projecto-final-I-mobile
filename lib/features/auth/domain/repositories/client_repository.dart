import 'package:dartz/dartz.dart' as dartz;

import '../../../../core/error/failures.dart';
import '../entities/user.dart';

abstract class ClientRepository {
  Future<dartz.Either<Failure, List<User>>> getClients();
}
