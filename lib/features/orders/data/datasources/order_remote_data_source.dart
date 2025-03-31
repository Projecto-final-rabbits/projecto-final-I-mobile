import '../models/order_model.dart';

abstract class OrderRemoteDataSource {
  Future<List<OrderModel>> getOrders();

  Future<OrderModel> getOrderDetail(String orderId);

  Future<OrderModel> createOrder(OrderModel order);
}
