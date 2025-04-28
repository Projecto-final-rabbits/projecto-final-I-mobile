import 'package:dartz/dartz.dart' as dartz;

import '../../../../core/error/failures.dart';
import '../entities/product.dart';

abstract class ProductRepository {
  Future<dartz.Either<Failure, List<Product>>> getProducts();
}
