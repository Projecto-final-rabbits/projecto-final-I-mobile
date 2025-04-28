import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/product.dart';
import '../../domain/usecases/get_products.dart';

part 'products_state.dart';

class ProductsCubit extends Cubit<ProductsState> {
  final GetProducts getProducts;

  ProductsCubit({required this.getProducts}) : super(ProductsInitial());

  Future<void> loadProducts() async {
    emit(ProductsLoading());

    final result = await getProducts();

    result.fold(
      (failure) => emit(ProductsError(message: failure.message)),
      (products) => emit(ProductsLoaded(products: products)),
    );
  }
}
