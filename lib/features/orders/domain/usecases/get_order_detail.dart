import 'package:cpp_app/features/orders/domain/entities/order_detail.dart';
import 'package:dartz/dartz.dart' as dartz;

import '../../../../core/error/failures.dart';
import '../repositories/order_repository.dart';

class GetOrderDetail {
  final OrderRepository repository;

  GetOrderDetail(this.repository);

  Future<dartz.Either<Failure, List<ProductDetail>>> call({
    required String orderId,
  }) async {
    return await repository.getOrderDetails(orderId);
  }
}
