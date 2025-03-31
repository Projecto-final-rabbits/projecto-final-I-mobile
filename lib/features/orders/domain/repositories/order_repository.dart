import 'package:dartz/dartz.dart' as dartz;

import '../../../../core/error/failures.dart';
import '../entities/order.dart';

abstract class OrderRepository {
  Future<dartz.Either<Failure, List<Order>>> getOrders();

  Future<dartz.Either<Failure, Order>> getOrderDetail(String orderId);

  Future<dartz.Either<Failure, Order>> createOrder(Order order);
}
