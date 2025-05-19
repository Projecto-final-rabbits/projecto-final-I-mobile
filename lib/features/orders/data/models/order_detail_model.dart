import 'package:cpp_app/features/orders/domain/entities/order_detail.dart';

import 'product_model.dart';

class OrderDetailModel extends ProductDetail {
  const OrderDetailModel({
    required super.id,
    required super.orderId,
    required super.productId,
    required super.quantity,
    required super.unitPrice,
    required super.product,
  });

  factory OrderDetailModel.fromJson(Map<String, dynamic> json) {
    return OrderDetailModel(
      id: json['id'],
      orderId: json['pedido_id'],
      productId: json['producto_id'],
      quantity: json['cantidad'],
      unitPrice: json['precio_unitario'],
      product: ProductModel.fromJson(json['producto']),
    );
  }
}
