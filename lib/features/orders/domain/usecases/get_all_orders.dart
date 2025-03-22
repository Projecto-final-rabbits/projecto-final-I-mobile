import 'package:dartz/dartz.dart' as dartz;

import '../../../../core/error/failures.dart';
import '../entities/order.dart';
import '../repositories/orders_repository.dart';

class GetAllOrders {
  final OrdersRepository repository;

  GetAllOrders(this.repository);

  Future<dartz.Either<Failure, List<Order>>> call() async {
    return await repository.getAllOrders();
  }
}
