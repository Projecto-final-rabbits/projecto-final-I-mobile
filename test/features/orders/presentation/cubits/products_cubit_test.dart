import 'package:cpp_app/core/error/failures.dart';
import 'package:cpp_app/features/orders/domain/entities/product.dart';
import 'package:cpp_app/features/orders/domain/usecases/get_products.dart';
import 'package:cpp_app/features/orders/presentation/cubits/products_cubit.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockGetProducts extends Mock implements GetProducts {}

void main() {
  late ProductsCubit cubit;
  late MockGetProducts mockGetProducts;

  setUp(() {
    mockGetProducts = MockGetProducts();
    cubit = ProductsCubit(getProducts: mockGetProducts);
  });

  tearDown(() {
    cubit.close();
  });

  group('ProductsCubit', () {
    final tProducts = [
      const Product(
        id: '1',
        name: 'Test Product 1',
        description: 'Description 1',
        salePrice: 100.0,
        category: 'Category 1',
        hasPromotion: false,
      ),
      const Product(
        id: '2',
        name: 'Test Product 2',
        description: 'Description 2',
        salePrice: 200.0,
        category: 'Category 2',
        hasPromotion: true,
      ),
    ];

    test('initial state should be ProductsInitial', () {
      expect(cubit.state, equals(ProductsInitial()));
    });

    test(
      'should emit [ProductsLoading, ProductsLoaded] when data is gotten successfully',
      () async {
        // arrange
        when(() => mockGetProducts()).thenAnswer((_) async => Right(tProducts));

        // assert later
        final expected = [
          ProductsLoading(),
          ProductsLoaded(products: tProducts),
        ];
        expectLater(cubit.stream, emitsInOrder(expected));

        // act
        await cubit.loadProducts();
      },
    );

    test(
      'should emit [ProductsLoading, ProductsError] when getting data fails',
      () async {
        // arrange
        when(() => mockGetProducts()).thenAnswer(
          (_) async => const Left(ServerFailure(message: 'Error message')),
        );

        // assert later
        final expected = [
          ProductsLoading(),
          const ProductsError(message: 'Error message'),
        ];
        expectLater(cubit.stream, emitsInOrder(expected));

        // act
        await cubit.loadProducts();
      },
    );
  });
}
