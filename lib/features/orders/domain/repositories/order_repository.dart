import 'package:cpp_app/features/orders/domain/entities/order_detail.dart';
import 'package:dartz/dartz.dart' as dartz;

import '../../../../core/error/failures.dart';
import '../entities/order.dart';

abstract class OrderRepository {
  Future<dartz.Either<Failure, List<Order>>> getOrders();

  Future<dartz.Either<Failure, List<ProductDetail>>> getOrderDetails(
    String orderId,
  );

  Future<dartz.Either<Failure, Order>> createOrder(Order order);
}
