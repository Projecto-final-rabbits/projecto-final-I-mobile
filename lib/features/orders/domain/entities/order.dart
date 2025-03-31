import 'package:cpp_app/features/orders/domain/entities/order_item.dart';
import 'package:equatable/equatable.dart';

class Order extends Equatable {
  final String id;
  final String customerName;
  final String customerEmail;
  final String customerPhone;
  final String status;
  final double total;
  final List<OrderItem> items;
  final DateTime createdAt;

  const Order({
    required this.id,
    required this.customerName,
    required this.customerEmail,
    required this.customerPhone,
    required this.status,
    required this.total,
    required this.items,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    customerName,
    customerEmail,
    customerPhone,
    status,
    total,
    items,
    createdAt,
  ];
}
