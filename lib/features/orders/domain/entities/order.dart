import 'package:equatable/equatable.dart';

class Order extends Equatable {
  final String id;
  final String customerName;
  final String productName;
  final double price;
  final String status;
  final DateTime createdAt;

  const Order({
    required this.id,
    required this.customerName,
    required this.productName,
    required this.price,
    required this.status,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    customerName,
    productName,
    price,
    status,
    createdAt,
  ];
}
