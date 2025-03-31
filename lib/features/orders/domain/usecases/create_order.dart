import 'package:dartz/dartz.dart' as dartz;

import '../../../../core/error/failures.dart';
import '../entities/order.dart';
import '../repositories/order_repository.dart';

class CreateOrder {
  final OrderRepository repository;

  CreateOrder(this.repository);

  Future<dartz.Either<Failure, Order>> call({required Order order}) async {
    return await repository.createOrder(order);
  }
}
