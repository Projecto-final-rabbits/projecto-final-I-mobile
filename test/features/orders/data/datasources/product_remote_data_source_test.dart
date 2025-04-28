import 'package:cpp_app/core/error/exceptions.dart';
import 'package:cpp_app/features/orders/data/datasources/product_remote_data_source_impl.dart';
import 'package:cpp_app/features/orders/data/models/product_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockDio extends Mock implements Dio {}

class MockResponse extends Mock implements Response {}

void main() {
  late ProductRemoteDataSourceImpl dataSource;
  late MockDio mockDio;

  setUp(() {
    mockDio = MockDio();
    dataSource = ProductRemoteDataSourceImpl(client: mockDio);
    registerFallbackValue(Uri());
  });

  final tProductsJson = [
    {
      'id': '1',
      'nombre': 'Test Product 1',
      'descripcion': 'Description 1',
      'precio_venta': 100.0,
      'categoria': 'Category 1',
      'promocion_activa': false,
    },
    {
      'id': '2',
      'nombre': 'Test Product 2',
      'descripcion': 'Description 2',
      'precio_venta': 200.0,
      'categoria': 'Category 2',
      'promocion_activa': true,
    },
  ];

  final tProducts = [
    ProductModel(
      id: '1',
      name: 'Test Product 1',
      description: 'Description 1',
      salePrice: 100.0,
      category: 'Category 1',
      hasPromotion: false,
    ),
    ProductModel(
      id: '2',
      name: 'Test Product 2',
      description: 'Description 2',
      salePrice: 200.0,
      category: 'Category 2',
      hasPromotion: true,
    ),
  ];

  group('getProducts', () {
    test(
      'should return list of ProductModel when the response code is 200',
      () async {
        // arrange
        final mockResponse = MockResponse();
        when(() => mockResponse.statusCode).thenReturn(200);
        when(() => mockResponse.data).thenReturn(tProductsJson);
        when(
          () => mockDio.get('/productos/'),
        ).thenAnswer((_) async => mockResponse);

        // act
        final result = await dataSource.getProducts();

        // assert
        expect(result, equals(tProducts));
        verify(() => mockDio.get('/productos/')).called(1);
      },
    );

    test(
      'should throw a ServerException when the response code is not 200',
      () async {
        // arrange
        final mockResponse = MockResponse();
        when(() => mockResponse.statusCode).thenReturn(404);
        when(
          () => mockDio.get('/productos/'),
        ).thenAnswer((_) async => mockResponse);

        // act
        final call = dataSource.getProducts;

        // assert
        expect(() => call(), throwsA(isA<ServerException>()));
        verify(() => mockDio.get('/productos/')).called(1);
      },
    );

    test('should throw a ServerException when Dio throws an error', () async {
      // arrange
      when(() => mockDio.get('/productos/')).thenThrow(Exception('Test error'));

      // act
      final call = dataSource.getProducts;

      // assert
      expect(() => call(), throwsA(isA<ServerException>()));
      verify(() => mockDio.get('/productos/')).called(1);
    });
  });
}
