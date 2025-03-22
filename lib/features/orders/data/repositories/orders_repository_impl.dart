import 'package:dartz/dartz.dart' as dartz;

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/order.dart';
import '../../domain/repositories/orders_repository.dart';
import '../datasources/orders_remote_data_source.dart';
import '../models/order_model.dart';

class OrdersRepositoryImpl implements OrdersRepository {
  final OrdersRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  OrdersRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<dartz.Either<Failure, List<Order>>> getAllOrders() async {
    if (await networkInfo.isConnected) {
      try {
        final remoteOrders = await remoteDataSource.getAllOrders();
        return dartz.Right(remoteOrders);
      } on ServerException {
        return dartz.Left(ServerFailure());
      }
    } else {
      return dartz.Left(NetworkFailure());
    }
  }

  @override
  Future<dartz.Either<Failure, Order>> getOrderDetails(String id) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteOrder = await remoteDataSource.getOrderDetails(id);
        return dartz.Right(remoteOrder);
      } on ServerException {
        return dartz.Left(ServerFailure());
      }
    } else {
      return dartz.Left(NetworkFailure());
    }
  }

  @override
  Future<dartz.Either<Failure, Order>> createOrder(Order order) async {
    if (await networkInfo.isConnected) {
      try {
        final orderModel = OrderModel(
          id: order.id,
          customerName: order.customerName,
          productName: order.productName,
          price: order.price,
          status: order.status,
          createdAt: order.createdAt,
        );
        final remoteOrder = await remoteDataSource.createOrder(orderModel);
        return dartz.Right(remoteOrder);
      } on ServerException {
        return dartz.Left(ServerFailure());
      }
    } else {
      return dartz.Left(NetworkFailure());
    }
  }

  @override
  Future<dartz.Either<Failure, void>> updateOrderStatus(
    String id,
    String status,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.updateOrderStatus(id, status);
        return const dartz.Right(null);
      } on ServerException {
        return dartz.Left(ServerFailure());
      }
    } else {
      return dartz.Left(NetworkFailure());
    }
  }
}
