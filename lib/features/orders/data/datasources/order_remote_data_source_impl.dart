import 'dart:convert';

import 'package:cpp_app/core/error/exceptions.dart';
import 'package:cpp_app/features/orders/data/datasources/order_remote_data_source.dart';
import 'package:cpp_app/features/orders/data/models/order_model.dart';
import 'package:dio/dio.dart';

class OrderRemoteDataSourceImpl implements OrderRemoteDataSource {
  final Dio client;

  OrderRemoteDataSourceImpl({required this.client});

  @override
  Future<List<OrderModel>> getOrders() async {
    try {
      final response = await client.get('/pedidos');

      if (response.statusCode == 200) {
        return (response.data as List)
            .map((json) => OrderModel.fromJson(json, withProducts: false))
            .toList();
      } else {
        throw ServerException(
          message: 'Failed to load orders: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw ServerException(message: 'Failed to load orders: ${e.toString()}');
    }
  }

  @override
  Future<OrderModel> getOrderDetail(String orderId) async {
    try {
      final response = await client.get('/pedidos/$orderId');

      if (response.statusCode == 200) {
        return OrderModel.fromJson(response.data);
      } else {
        throw ServerException(
          message: 'Failed to load order details: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw ServerException(
        message: 'Failed to load order details: ${e.toString()}',
      );
    }
  }

  @override
  Future<OrderModel> createOrder(OrderModel order) async {
    try {
      final response = await client.post(
        '/pedidos',
        data: json.encode(order.toJson()),
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return OrderModel.fromJson(response.data);
      } else {
        throw ServerException(
          message: 'Failed to create order: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw ServerException(
        message:
            'Failed to create order: ${e.response?.statusMessage ?? e.message}',
      );
    } catch (e) {
      throw ServerException(message: 'Failed to create order: ${e.toString()}');
    }
  }
}
