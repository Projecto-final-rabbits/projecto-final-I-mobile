import 'package:dartz/dartz.dart' as dartz;

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../data/datasources/product_remote_data_source.dart';
import '../entities/product.dart';
import 'product_repository.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  ProductRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<dartz.Either<Failure, List<Product>>> getProducts() async {
    if (await networkInfo.isConnected) {
      try {
        final remoteProducts = await remoteDataSource.getProducts();
        return dartz.Right(remoteProducts);
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
