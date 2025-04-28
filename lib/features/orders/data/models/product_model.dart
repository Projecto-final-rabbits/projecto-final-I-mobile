import 'package:cpp_app/features/orders/domain/entities/product.dart';

class ProductModel extends Product {
  const ProductModel({
    required super.id,
    required super.name,
    required super.description,
    required super.salePrice,
    required super.category,
    required super.hasPromotion,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'],
      name: json['nombre'],
      description: json['descripcion'],
      salePrice: json['precio_venta'],
      category: json['categoria'],
      hasPromotion: json['promocion_activa'],
    );
  }
}
