import 'package:cpp_app/features/orders/domain/entities/order_item.dart';

class OrderItemModel extends OrderItem {
  const OrderItemModel({required super.productId, required super.quantity});

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      productId: json['producto_id'],
      quantity: json['cantidad'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'producto_id': productId, 'cantidad': quantity};
  }
}
