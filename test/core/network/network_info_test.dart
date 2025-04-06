import 'package:cpp_app/core/network/network_info.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:mocktail/mocktail.dart';

class MockInternetConnectionChecker extends Mock
    implements InternetConnectionChecker {}

void main() {
  late NetworkInfoImpl networkInfo;
  late MockInternetConnectionChecker mockConnectionChecker;

  setUp(() {
    mockConnectionChecker = MockInternetConnectionChecker();
    networkInfo = NetworkInfoImpl(mockConnectionChecker);
  });

  group('isConnected', () {
    test(
      'should forward the call to InternetConnectionChecker.hasConnection',
      () async {
        // arrange
        final tHasConnectionFuture = Future.value(true);
        when(
          () => mockConnectionChecker.hasConnection,
        ).thenAnswer((_) => tHasConnectionFuture);

        // act
        final result = networkInfo.isConnected;

        // assert
        verify(() => mockConnectionChecker.hasConnection).called(1);
        expect(result, tHasConnectionFuture);
      },
    );

    test(
      'should return true when InternetConnectionChecker returns true',
      () async {
        // arrange
        when(
          () => mockConnectionChecker.hasConnection,
        ).thenAnswer((_) => Future.value(true));

        // act
        final result = await networkInfo.isConnected;

        // assert
        expect(result, true);
      },
    );

    test(
      'should return false when InternetConnectionChecker returns false',
      () async {
        // arrange
        when(
          () => mockConnectionChecker.hasConnection,
        ).thenAnswer((_) => Future.value(false));

        // act
        final result = await networkInfo.isConnected;

        // assert
        expect(result, false);
      },
    );
  });
}
