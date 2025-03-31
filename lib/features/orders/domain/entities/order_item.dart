import 'package:equatable/equatable.dart';

class OrderItem extends Equatable {
  final String id;
  final String name;
  final int quantity;
  final double price;

  const OrderItem({
    required this.id,
    required this.name,
    required this.quantity,
    required this.price,
  });

  @override
  List<Object?> get props => [id, name, quantity, price];
}
