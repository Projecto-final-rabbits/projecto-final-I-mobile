import 'package:equatable/equatable.dart';

class Product extends Equatable {
  final String id;
  final String name;
  final String description;
  final double salePrice;
  final String category;
  final bool hasPromotion;

  const Product({
    required this.id,
    required this.name,
    required this.description,
    required this.salePrice,
    required this.category,
    required this.hasPromotion,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    salePrice,
    category,
    hasPromotion,
  ];
}
