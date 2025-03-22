import 'package:dartz/dartz.dart' as dartz;
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../entities/order.dart';
import '../repositories/orders_repository.dart';

class GetOrderDetails {
  final OrdersRepository repository;

  GetOrderDetails(this.repository);

  Future<dartz.Either<Failure, Order>> call(Params params) async {
    return await repository.getOrderDetails(params.id);
  }
}

class Params extends Equatable {
  final String id;

  const Params({required this.id});

  @override
  List<Object?> get props => [id];
}
