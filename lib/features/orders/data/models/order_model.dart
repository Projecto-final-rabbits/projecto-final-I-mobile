import 'package:cpp_app/features/orders/data/models/order_item_model.dart';

import '../../domain/entities/order.dart';

class OrderModel extends Order {
  const OrderModel({
    required super.id,
    required super.customerName,
    required super.customerEmail,
    required super.customerPhone,
    required super.status,
    required super.total,
    required List<OrderItemModel> super.items,
    required super.createdAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'],
      customerName: json['customerName'],
      customerEmail: json['customerEmail'],
      customerPhone: json['customerPhone'],
      status: json['status'],
      total: json['total'].toDouble(),
      items:
          (json['items'] as List)
              .map((item) => OrderItemModel.fromJson(item))
              .toList(),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customerName': customerName,
      'customerEmail': customerEmail,
      'customerPhone': customerPhone,
      'status': status,
      'total': total,
      'items':
          (items as List<OrderItemModel>).map((item) => item.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
