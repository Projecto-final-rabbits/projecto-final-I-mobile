import 'package:cpp_app/features/orders/domain/entities/product.dart';
import 'package:equatable/equatable.dart';

class Order extends Equatable {
  final int id;
  final int clientId;
  final int sellerId;
  final DateTime shipDate;
  final String deliveryAddress;
  final List<Product> products;
  final String status;
  final double total;

  const Order({
    required this.id,
    required this.clientId,
    required this.sellerId,
    required this.shipDate,
    required this.deliveryAddress,
    required this.products,
    required this.status,
    required this.total,
  });

  @override
  List<Object?> get props => [
    id,
    clientId,
    sellerId,
    shipDate,
    deliveryAddress,
    products,
    status,
    total,
  ];
}
