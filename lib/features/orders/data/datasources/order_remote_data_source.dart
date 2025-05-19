import 'package:cpp_app/features/orders/data/models/order_detail_model.dart';

import '../models/order_model.dart';

abstract class OrderRemoteDataSource {
  Future<List<OrderModel>> getOrders();

  Future<List<OrderDetailModel>> getOrderDetails(String orderId);

  Future<OrderModel> createOrder(OrderModel order);
}
