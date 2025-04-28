import 'package:cpp_app/features/orders/data/models/order_item_model.dart';
import 'package:cpp_app/features/orders/data/models/product_model.dart';

import '../../domain/entities/order.dart';

class OrderModel extends Order {
  const OrderModel({
    required super.id,
    required super.clientId,
    required super.sellerId,
    required super.shipDate,
    required super.deliveryAddress,
    required super.status,
    required super.total,
    required super.products,
  });

  factory OrderModel.fromJson(
    Map<String, dynamic> json, {
    bool withProducts = true,
  }) {
    return OrderModel(
      id: json['id'],
      clientId: json['cliente_id'],
      sellerId: json['vendedor_id'],
      shipDate: DateTime.parse(json['fecha_envio']),
      deliveryAddress: json['direccion_entrega'],
      status: json['estado'],
      total: json['total'].toDouble(),
      products:
          withProducts
              ? (json['productos'] as List)
                  .map((item) => ProductModel.fromJson(item))
                  .toList()
              : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cliente_id': clientId,
      'vendedor_id': sellerId,
      'fecha_envio': shipDate.toIso8601String(),
      'direccion_entrega': deliveryAddress,
      'estado': status,
      'total': total,
      'productos':
          (products as List<OrderItemModel>)
              .map((item) => item.toJson())
              .toList(),
    };
  }
}
