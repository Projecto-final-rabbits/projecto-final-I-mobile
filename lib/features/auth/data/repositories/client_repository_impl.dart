import 'package:dartz/dartz.dart' as dartz;

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/client_repository.dart';
import '../datasources/client_remote_data_source.dart';

class ClientRepositoryImpl implements ClientRepository {
  final ClientRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  ClientRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<dartz.Either<Failure, List<User>>> getClients() async {
    if (await networkInfo.isConnected) {
      try {
        final remoteClients = await remoteDataSource.getClients();
        return dartz.Right(remoteClients);
      } on ServerException catch (e) {
        return dartz.Left(ServerFailure(message: e.message));
      }
    } else {
      return dartz.Left(
        const NetworkFailure(message: 'No internet connection'),
      );
    }
  }
}
