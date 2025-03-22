import 'package:dartz/dartz.dart' as dartz;
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../entities/order.dart';
import '../repositories/orders_repository.dart';

class CreateOrder {
  final OrdersRepository repository;

  CreateOrder(this.repository);

  Future<dartz.Either<Failure, Order>> call(Params params) async {
    return await repository.createOrder(params.order);
  }
}

class Params extends Equatable {
  final Order order;

  const Params({required this.order});

  @override
  List<Object?> get props => [order];
}
