import 'package:cpp_app/features/orders/data/models/product_model.dart';
import 'package:cpp_app/features/orders/domain/entities/order_item.dart';
import 'package:cpp_app/features/orders/domain/entities/product.dart';

import '../../domain/entities/order.dart';

/// OrderModel represents an order in the system and handles conversion between
/// the domain entity and the API format.
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

  /// Converts the order to the expected API format
  /// The productos field should be in the format:
  /// [{'producto_id': '<uuid>', 'cantidad': <int>}, ...]
  Map<String, dynamic> toJson() {
    final List<Map<String, dynamic>> productsList = [];

    // Convert products to API format
    for (var item in products) {
      if (item is Product) {
        productsList.add({
          'producto_id': item.id,
          'cantidad': 1, // Default quantity
        });
      } else if (item is OrderItem) {
        productsList.add({
          'producto_id': item.productId,
          'cantidad': item.quantity,
        });
      }
    }

    return {
      'cliente_id': clientId,
      'vendedor_id': sellerId,
      'fecha_envio':
          shipDate.toIso8601String().split('T')[0], // Format as YYYY-MM-DD
      'direccion_entrega': deliveryAddress,
      'estado': status,
      'total': total,
      'productos': productsList,
    };
  }
}
