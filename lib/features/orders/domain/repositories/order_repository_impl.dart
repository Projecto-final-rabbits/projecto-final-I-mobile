import 'package:cpp_app/features/orders/domain/entities/order_detail.dart';
import 'package:dartz/dartz.dart' as dartz;

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../data/datasources/order_remote_data_source.dart';
import '../../data/models/order_model.dart';
import '../entities/order.dart';
import 'order_repository.dart';

class OrderRepositoryImpl implements OrderRepository {
  final OrderRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  OrderRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<dartz.Either<Failure, List<Order>>> getOrders() async {
    if (await networkInfo.isConnected) {
      try {
        final remoteOrders = await remoteDataSource.getOrders();
        return dartz.Right(remoteOrders);
      } on ServerException catch (e) {
        return dartz.Left(ServerFailure(message: e.message));
      }
    } else {
      return dartz.Left(
        const NetworkFailure(message: 'No internet connection'),
      );
    }
  }

  @override
  Future<dartz.Either<Failure, List<ProductDetail>>> getOrderDetails(
    String orderId,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        final orderDetails = await remoteDataSource.getOrderDetails(orderId);
        return dartz.Right(orderDetails);
      } on ServerException catch (e) {
        return dartz.Left(ServerFailure(message: e.message));
      }
    } else {
      return dartz.Left(
        const NetworkFailure(message: 'No internet connection'),
      );
    }
  }

  @override
  Future<dartz.Either<Failure, Order>> createOrder(Order order) async {
    if (await networkInfo.isConnected) {
      try {
        final orderModel = OrderModel(
          id: order.id,
          clientId: order.clientId,
          sellerId: order.sellerId,
          shipDate: order.shipDate,
          deliveryAddress: order.deliveryAddress,
          status: order.status,
          total: order.total,
          products: order.products,
        );

        final newOrder = await remoteDataSource.createOrder(orderModel);
        return dartz.Right(newOrder);
      } on ServerException catch (e) {
        return dartz.Left(ServerFailure(message: e.message));
      }
    } else {
      return dartz.Left(
        const NetworkFailure(message: 'No internet connection'),
      );
    }
  }
}
