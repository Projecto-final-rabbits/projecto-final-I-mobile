import 'dart:convert';

import 'package:cpp_app/core/error/exceptions.dart';
import 'package:cpp_app/features/orders/data/datasources/order_remote_data_source_impl.dart';
import 'package:cpp_app/features/orders/data/models/order_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockDio extends Mock implements Dio {}

class MockResponse extends Mock implements Response {}

void main() {
  late OrderRemoteDataSourceImpl dataSource;
  late MockDio mockDio;

  setUp(() {
    mockDio = MockDio();
    dataSource = OrderRemoteDataSourceImpl(client: mockDio);
    registerFallbackValue(Uri());
  });

  final tOrderModel = OrderModel(
    id: '1',
    customerName: 'Test Customer',
    customerEmail: 'test@example.com',
    customerPhone: '1234567890',
    status: 'Pending',
    total: 100.0,
    items: [],
    createdAt: DateTime.parse('2023-01-01'),
  );

  final tOrderModelJson = {
    'id': '1',
    'customerName': 'Test Customer',
    'customerEmail': 'test@example.com',
    'customerPhone': '1234567890',
    'status': 'Pending',
    'total': 100.0,
    'items': [],
    'createdAt': '2023-01-01T00:00:00.000',
  };

  final tOrdersJson = [
    {
      'id': '1',
      'customerName': 'Test Customer',
      'customerEmail': 'test@example.com',
      'customerPhone': '1234567890',
      'status': 'Pending',
      'total': 100.0,
      'items': [],
      'createdAt': '2023-01-01T00:00:00.000',
    },
    {
      'id': '2',
      'customerName': 'Another Customer',
      'customerEmail': 'another@example.com',
      'customerPhone': '0987654321',
      'status': 'Completed',
      'total': 200.0,
      'items': [],
      'createdAt': '2023-01-02T00:00:00.000',
    },
  ];

  group('getOrders', () {
    test(
      'should return List<OrderModel> when the response code is 200',
      () async {
        // arrange
        final response = Response(
          data: tOrdersJson,
          statusCode: 200,
          requestOptions: RequestOptions(path: '/orders'),
        );
        when(() => mockDio.get('/orders')).thenAnswer((_) async => response);

        // act
        final result = await dataSource.getOrders();

        // assert
        expect(result, isA<List<OrderModel>>());
        expect(result.length, equals(2));
        verify(() => mockDio.get('/orders')).called(1);
      },
    );

    test(
      'should throw a ServerException when the response code is not 200',
      () async {
        // arrange
        final response = Response(
          data: 'Error',
          statusCode: 404,
          requestOptions: RequestOptions(path: '/orders'),
        );
        when(() => mockDio.get('/orders')).thenAnswer((_) async => response);

        // act
        final call = dataSource.getOrders;

        // assert
        expect(() => call(), throwsA(isA<ServerException>()));
      },
    );

    test('should throw a ServerException when Dio throws an error', () async {
      // arrange
      when(() => mockDio.get('/orders')).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/orders'),
          error: 'Test error',
        ),
      );

      // act
      final call = dataSource.getOrders;

      // assert
      expect(() => call(), throwsA(isA<ServerException>()));
    });
  });

  group('getOrderDetail', () {
    const tOrderId = '1';

    test('should return OrderModel when the response code is 200', () async {
      // arrange
      final response = Response(
        data: tOrderModelJson,
        statusCode: 200,
        requestOptions: RequestOptions(path: '/orders/$tOrderId'),
      );
      when(
        () => mockDio.get('/orders/$tOrderId'),
      ).thenAnswer((_) async => response);

      // act
      final result = await dataSource.getOrderDetail(tOrderId);

      // assert
      expect(result, isA<OrderModel>());
      expect(result.id, equals(tOrderId));
      verify(() => mockDio.get('/orders/$tOrderId')).called(1);
    });

    test(
      'should throw a ServerException when the response code is not 200',
      () async {
        // arrange
        final response = Response(
          data: 'Error',
          statusCode: 404,
          requestOptions: RequestOptions(path: '/orders/$tOrderId'),
        );
        when(
          () => mockDio.get('/orders/$tOrderId'),
        ).thenAnswer((_) async => response);

        // act
        call() => dataSource.getOrderDetail(tOrderId);

        // assert
        expect(call, throwsA(isA<ServerException>()));
      },
    );

    test('should throw a ServerException when Dio throws an error', () async {
      // arrange
      when(() => mockDio.get('/orders/$tOrderId')).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/orders/$tOrderId'),
          error: 'Test error',
        ),
      );

      // act
      call() => dataSource.getOrderDetail(tOrderId);

      // assert
      expect(call, throwsA(isA<ServerException>()));
    });
  });

  group('createOrder', () {
    test('should return OrderModel when the response code is 201', () async {
      // arrange
      final response = Response(
        data: tOrderModelJson,
        statusCode: 201,
        requestOptions: RequestOptions(path: '/orders'),
      );
      when(
        () => mockDio.post('/orders', data: any(named: 'data')),
      ).thenAnswer((_) async => response);

      // act
      final result = await dataSource.createOrder(tOrderModel);

      // assert
      expect(result, isA<OrderModel>());
      expect(result.id, equals(tOrderModel.id));
      verify(
        () => mockDio.post('/orders', data: json.encode(tOrderModel.toJson())),
      ).called(1);
    });

    test(
      'should throw a ServerException when the response code is not 201',
      () async {
        // arrange
        final response = Response(
          data: 'Error',
          statusCode: 400,
          requestOptions: RequestOptions(path: '/orders'),
        );
        when(
          () => mockDio.post('/orders', data: any(named: 'data')),
        ).thenAnswer((_) async => response);

        // act
        call() => dataSource.createOrder(tOrderModel);

        // assert
        expect(call, throwsA(isA<ServerException>()));
      },
    );

    test('should throw a ServerException when Dio throws an error', () async {
      // arrange
      when(() => mockDio.post('/orders', data: any(named: 'data'))).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/orders'),
          error: 'Test error',
        ),
      );

      // act
      call() => dataSource.createOrder(tOrderModel);

      // assert
      expect(call, throwsA(isA<ServerException>()));
    });
  });
}
