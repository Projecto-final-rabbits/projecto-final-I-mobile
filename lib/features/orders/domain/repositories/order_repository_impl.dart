import 'package:cpp_app/features/orders/data/models/order_item_model.dart';
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
  Future<dartz.Either<Failure, Order>> getOrderDetail(String orderId) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteOrder = await remoteDataSource.getOrderDetail(orderId);
        return dartz.Right(remoteOrder);
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
          customerName: order.customerName,
          customerEmail: order.customerEmail,
          customerPhone: order.customerPhone,
          status: order.status,
          total: order.total,
          items:
              order.items
                  .map(
                    (item) => OrderItemModel(
                      id: item.id,
                      name: item.name,
                      quantity: item.quantity,
                      price: item.price,
                    ),
                  )
                  .toList(),
          createdAt: order.createdAt,
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
