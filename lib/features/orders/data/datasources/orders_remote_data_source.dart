import 'dart:convert';

import 'package:cpp_app/features/orders/data/datasources/orders_mock.dart';
import 'package:dio/dio.dart';

import '../../../../core/error/exceptions.dart';
import '../models/order_model.dart';

abstract class OrdersRemoteDataSource {
  /// Calls the api endpoint to get all orders
  /// Throws a [ServerException] for all error codes
  Future<List<OrderModel>> getAllOrders();

  /// Calls the api endpoint to get order details
  /// Throws a [ServerException] for all error codes
  Future<OrderModel> getOrderDetails(String id);

  /// Calls the api endpoint to create an order
  /// Throws a [ServerException] for all error codes
  Future<OrderModel> createOrder(OrderModel order);

  /// Calls the api endpoint to update order status
  /// Throws a [ServerException] for all error codes
  Future<void> updateOrderStatus(String id, String status);
}

class OrdersRemoteDataSourceImpl implements OrdersRemoteDataSource {
  final Dio client;

  OrdersRemoteDataSourceImpl({required this.client});

  @override
  Future<List<OrderModel>> getAllOrders() async {
    try {
      // final response = await client.get('/orders');

      // if (response.statusCode == 200) {
      final List<dynamic> ordersList = ordersMock;
      return ordersList.map((json) => OrderModel.fromJson(json)).toList();
      // } else {
      //   throw ServerException();
      // }
    } catch (e) {
      throw ServerException();
    }
  }

  @override
  Future<OrderModel> getOrderDetails(String id) async {
    try {
      final response = await client.get('/orders/$id');

      if (response.statusCode == 200) {
        return OrderModel.fromJson(response.data);
      } else {
        throw ServerException();
      }
    } catch (e) {
      throw ServerException();
    }
  }

  @override
  Future<OrderModel> createOrder(OrderModel order) async {
    try {
      final response = await client.post(
        '/orders',
        data: jsonEncode(order.toJson()),
      );

      if (response.statusCode == 201) {
        return OrderModel.fromJson(response.data);
      } else {
        throw ServerException();
      }
    } catch (e) {
      throw ServerException();
    }
  }

  @override
  Future<void> updateOrderStatus(String id, String status) async {
    try {
      final response = await client.patch(
        '/orders/$id',
        data: jsonEncode({'status': status}),
      );

      if (response.statusCode != 200) {
        throw ServerException();
      }
    } catch (e) {
      throw ServerException();
    }
  }
}
