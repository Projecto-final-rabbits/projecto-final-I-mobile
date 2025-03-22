import 'package:dartz/dartz.dart' as dartz;

import '../../../../core/error/failures.dart';
import '../entities/order.dart';

abstract class OrdersRepository {
  Future<dartz.Either<Failure, List<Order>>> getAllOrders();
  Future<dartz.Either<Failure, Order>> getOrderDetails(String id);
  Future<dartz.Either<Failure, Order>> createOrder(Order order);
  Future<dartz.Either<Failure, void>> updateOrderStatus(
    String id,
    String status,
  );
}
