import 'package:dartz/dartz.dart' as dartz;

import '../../../../core/error/failures.dart';
import '../entities/order.dart';
import '../repositories/order_repository.dart';

class GetOrderDetail {
  final OrderRepository repository;

  GetOrderDetail(this.repository);

  Future<dartz.Either<Failure, Order>> call({required String orderId}) async {
    return await repository.getOrderDetail(orderId);
  }
}
