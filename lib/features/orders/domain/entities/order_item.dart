import 'package:equatable/equatable.dart';

class OrderItem extends Equatable {
  final String productId;
  final int quantity;

  const OrderItem({required this.productId, required this.quantity});

  @override
  List<Object?> get props => [productId, quantity];
}
