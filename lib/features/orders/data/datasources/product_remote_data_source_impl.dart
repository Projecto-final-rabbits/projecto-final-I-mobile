import 'package:cpp_app/core/error/exceptions.dart';
import 'package:cpp_app/features/orders/data/datasources/product_remote_data_source.dart';
import 'package:cpp_app/features/orders/data/models/product_model.dart';
import 'package:dio/dio.dart';

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final Dio client;

  ProductRemoteDataSourceImpl({required this.client});

  @override
  Future<List<ProductModel>> getProducts() async {
    try {
      final response = await client.get('/productos/');

      if (response.statusCode == 200) {
        return (response.data as List)
            .map((json) => ProductModel.fromJson(json))
            .toList();
      } else {
        throw ServerException(
          message: 'Failed to load products: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw ServerException(
        message: 'Failed to load products: ${e.toString()}',
      );
    }
  }
}
