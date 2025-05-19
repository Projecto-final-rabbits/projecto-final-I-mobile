import 'package:equatable/equatable.dart';

import 'product.dart';

class ProductDetail extends Equatable {
  final int id;
  final int orderId;
  final String productId;
  final int quantity;
  final double unitPrice;
  final Product product;

  const ProductDetail({
    required this.id,
    required this.orderId,
    required this.productId,
    required this.quantity,
    required this.unitPrice,
    required this.product,
  });

  @override
  List<Object?> get props => [
    id,
    orderId,
    productId,
    quantity,
    unitPrice,
    product,
  ];
}
