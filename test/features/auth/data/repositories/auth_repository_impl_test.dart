import 'package:cpp_app/core/error/exceptions.dart';
import 'package:cpp_app/core/error/failures.dart';
import 'package:cpp_app/core/network/network_info.dart';
import 'package:cpp_app/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:cpp_app/features/auth/data/models/user_model.dart'; // Import UserModel
import 'package:cpp_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:cpp_app/features/auth/domain/entities/user.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// Mocks
class MockAuthRemoteDataSource extends Mock implements AuthRemoteDataSource {}

class MockNetworkInfo extends Mock implements NetworkInfo {}

void main() {
  late AuthRepositoryImpl repository;
  late MockAuthRemoteDataSource mockRemoteDataSource;
  late MockNetworkInfo mockNetworkInfo;

  setUp(() {
    mockRemoteDataSource = MockAuthRemoteDataSource();
    mockNetworkInfo = MockNetworkInfo();
    repository = AuthRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      networkInfo: mockNetworkInfo,
    );
  });

  // Helper function to run tests for online/offline scenarios
  void runTestsOnline(Function body) {
    group('device is online', () {
      setUp(() {
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      });
      body();
    });
  }

  void runTestsOffline(Function body) {
    group('device is offline', () {
      setUp(() {
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => false);
      });
      body();
    });
  }

  group('signInWithEmailAndPassword', () {
    const tEmail = 'test@example.com';
    const tPassword = 'password';
    // Use UserModel for remote data source response, as repository maps it to User entity
    final tUserModel = UserModel(id: '1', email: tEmail, role: UserRole.client);
    final User tUser = tUserModel; // UserModel extends User

    runTestsOnline(() {
      test(
        'should return User when remote data source call is successful',
        () async {
          // Arrange
          when(
            () => mockRemoteDataSource.signInWithEmailAndPassword(any(), any()),
          ).thenAnswer((_) async => tUserModel);
          // Act
          final result = await repository.signInWithEmailAndPassword(
            tEmail,
            tPassword,
          );
          // Assert
          expect(result, Right(tUser));
          verify(
            () => mockRemoteDataSource.signInWithEmailAndPassword(
              tEmail,
              tPassword,
            ),
          );
        },
      );

      test(
        'should return AuthFailure when remote data source throws AuthException',
        () async {
          // Arrange
          final tException = AuthException(message: 'Invalid credentials');
          when(
            () => mockRemoteDataSource.signInWithEmailAndPassword(any(), any()),
          ).thenThrow(tException);
          // Act
          final result = await repository.signInWithEmailAndPassword(
            tEmail,
            tPassword,
          );
          // Assert
          expect(result, Left(AuthFailure(message: tException.message)));
          verify(
            () => mockRemoteDataSource.signInWithEmailAndPassword(
              tEmail,
              tPassword,
            ),
          );
        },
      );

      test('should return UnexpectedFailure for other exceptions', () async {
        // Arrange
        final tException = Exception('Something went wrong');
        when(
          () => mockRemoteDataSource.signInWithEmailAndPassword(any(), any()),
        ).thenThrow(tException);
        // Act
        final result = await repository.signInWithEmailAndPassword(
          tEmail,
          tPassword,
        );
        // Assert
        expect(result, Left(UnexpectedFailure(message: tException.toString())));
        verify(
          () => mockRemoteDataSource.signInWithEmailAndPassword(
            tEmail,
            tPassword,
          ),
        );
      });
    });

    runTestsOffline(() {
      test('should return NetworkFailure when device is offline', () async {
        // Act
        final result = await repository.signInWithEmailAndPassword(
          tEmail,
          tPassword,
        );
        // Assert
        expect(
          result,
          const Left(NetworkFailure(message: 'No hay conexión a Internet')),
        );
        verifyNever(
          () => mockRemoteDataSource.signInWithEmailAndPassword(any(), any()),
        );
      });
    });
  });

  // --- signUpClient Tests ---
  group('signUpClient', () {
    const tEmail = 'client@example.com';
    const tPassword = 'password';
    const tName = 'Client Name';
    const tClientType = 'TypeA';
    const tAddress = '123 Street';
    const tPhone = '1234567890';
    final tUserModel = UserModel(
      id: 'c1',
      email: tEmail,
      role: UserRole.client,
      name: tName,
      clientType: tClientType,
      address: tAddress,
      phone: tPhone,
    );
    final User tUser = tUserModel;

    runTestsOnline(() {
      test('should return User when remote call is successful', () async {
        // Arrange
        when(
          () => mockRemoteDataSource.signUpClient(
            any(),
            any(),
            any(),
            any(),
            any(),
            any(),
          ),
        ).thenAnswer((_) async => tUserModel);
        // Act
        final result = await repository.signUpClient(
          tEmail,
          tPassword,
          tName,
          tClientType,
          tAddress,
          tPhone,
        );
        // Assert
        expect(result, Right(tUser));
        verify(
          () => mockRemoteDataSource.signUpClient(
            tEmail,
            tPassword,
            tName,
            tClientType,
            tAddress,
            tPhone,
          ),
        );
      });

      test(
        'should return AuthFailure when remote data source throws AuthException',
        () async {
          // Arrange
          final tException = AuthException(message: 'Email already exists');
          when(
            () => mockRemoteDataSource.signUpClient(
              any(),
              any(),
              any(),
              any(),
              any(),
              any(),
            ),
          ).thenThrow(tException);
          // Act
          final result = await repository.signUpClient(
            tEmail,
            tPassword,
            tName,
            tClientType,
            tAddress,
            tPhone,
          );
          // Assert
          expect(result, Left(AuthFailure(message: tException.message)));
        },
      );

      test('should return UnexpectedFailure for other exceptions', () async {
        // Arrange
        final tException = Exception('Generic error');
        when(
          () => mockRemoteDataSource.signUpClient(
            any(),
            any(),
            any(),
            any(),
            any(),
            any(),
          ),
        ).thenThrow(tException);
        // Act
        final result = await repository.signUpClient(
          tEmail,
          tPassword,
          tName,
          tClientType,
          tAddress,
          tPhone,
        );
        // Assert
        expect(result, Left(UnexpectedFailure(message: tException.toString())));
      });
    });

    runTestsOffline(() {
      test('should return NetworkFailure when device is offline', () async {
        // Act
        final result = await repository.signUpClient(
          tEmail,
          tPassword,
          tName,
          tClientType,
          tAddress,
          tPhone,
        );
        // Assert
        expect(
          result,
          const Left(NetworkFailure(message: 'No hay conexión a Internet')),
        );
        verifyNever(
          () => mockRemoteDataSource.signUpClient(
            any(),
            any(),
            any(),
            any(),
            any(),
            any(),
          ),
        );
      });
    });
  });

  // --- signUpSeller Tests ---
  group('signUpSeller', () {
    const tEmail = 'seller@example.com';
    const tPassword = 'password';
    const tName = 'Seller Name';
    const tZone = 'ZoneA';
    const tPhone = '0987654321';
    final tUserModel = UserModel(
      id: 's1',
      email: tEmail,
      role: UserRole.seller,
      name: tName,
      zone: tZone,
      phone: tPhone,
    );
    final User tUser = tUserModel;

    runTestsOnline(() {
      test('should return User when remote call is successful', () async {
        // Arrange
        when(
          () => mockRemoteDataSource.signUpSeller(
            any(),
            any(),
            any(),
            any(),
            any(),
          ),
        ).thenAnswer((_) async => tUserModel);
        // Act
        final result = await repository.signUpSeller(
          tEmail,
          tPassword,
          tName,
          tZone,
          tPhone,
        );
        // Assert
        expect(result, Right(tUser));
        verify(
          () => mockRemoteDataSource.signUpSeller(
            tEmail,
            tPassword,
            tName,
            tZone,
            tPhone,
          ),
        );
      });

      test(
        'should return AuthFailure when remote data source throws AuthException',
        () async {
          // Arrange
          final tException = AuthException(message: 'Seller error');
          when(
            () => mockRemoteDataSource.signUpSeller(
              any(),
              any(),
              any(),
              any(),
              any(),
            ),
          ).thenThrow(tException);
          // Act
          final result = await repository.signUpSeller(
            tEmail,
            tPassword,
            tName,
            tZone,
            tPhone,
          );
          // Assert
          expect(result, Left(AuthFailure(message: tException.message)));
        },
      );

      test('should return UnexpectedFailure for other exceptions', () async {
        // Arrange
        final tException = Exception('Server error');
        when(
          () => mockRemoteDataSource.signUpSeller(
            any(),
            any(),
            any(),
            any(),
            any(),
          ),
        ).thenThrow(tException);
        // Act
        final result = await repository.signUpSeller(
          tEmail,
          tPassword,
          tName,
          tZone,
          tPhone,
        );
        // Assert
        expect(result, Left(UnexpectedFailure(message: tException.toString())));
      });
    });

    runTestsOffline(() {
      test('should return NetworkFailure when device is offline', () async {
        // Act
        final result = await repository.signUpSeller(
          tEmail,
          tPassword,
          tName,
          tZone,
          tPhone,
        );
        // Assert
        expect(
          result,
          const Left(NetworkFailure(message: 'No hay conexión a Internet')),
        );
        verifyNever(
          () => mockRemoteDataSource.signUpSeller(
            any(),
            any(),
            any(),
            any(),
            any(),
          ),
        );
      });
    });
  });

  // --- signOut Tests ---
  group('signOut', () {
    // No online/offline check needed as per implementation
    test(
      'should call remoteDataSource.signOut and return Right(null) on success',
      () async {
        // Arrange
        when(
          () => mockRemoteDataSource.signOut(),
        ).thenAnswer((_) async => Future.value());
        // Act
        final result = await repository.signOut();
        // Assert
        expect(result, const Right(null));
        verify(() => mockRemoteDataSource.signOut());
      },
    );

    test(
      'should return AuthFailure when remoteDataSource throws AuthException',
      () async {
        // Arrange
        final tException = AuthException(message: 'Sign out failed');
        when(() => mockRemoteDataSource.signOut()).thenThrow(tException);
        // Act
        final result = await repository.signOut();
        // Assert
        expect(result, Left(AuthFailure(message: tException.message)));
        verify(() => mockRemoteDataSource.signOut());
      },
    );

    test('should return UnexpectedFailure for other exceptions', () async {
      // Arrange
      final tException = Exception('Unexpected error');
      when(() => mockRemoteDataSource.signOut()).thenThrow(tException);
      // Act
      final result = await repository.signOut();
      // Assert
      expect(result, Left(UnexpectedFailure(message: tException.toString())));
      verify(() => mockRemoteDataSource.signOut());
    });

    // Note: The current implementation doesn't check network connectivity for signOut.
    // If it should, add offline tests.
  });

  // --- getCurrentUser Tests ---
  group('getCurrentUser', () {
    // No online/offline check needed as per implementation
    final tUserModel = UserModel(
      id: '1',
      email: 'current@example.com',
      role: UserRole.client,
    );
    final User tUser = tUserModel;
    const User? tNullUser = null;

    test('should return User? from remoteDataSource on success', () async {
      // Arrange
      when(
        () => mockRemoteDataSource.getCurrentUser(),
      ).thenAnswer((_) async => tUserModel);
      // Act
      final result = await repository.getCurrentUser();
      // Assert
      expect(result, Right(tUser));
      verify(() => mockRemoteDataSource.getCurrentUser());
    });

    test(
      'should return Right(null) when remoteDataSource returns null',
      () async {
        // Arrange
        when(
          () => mockRemoteDataSource.getCurrentUser(),
        ).thenAnswer((_) async => null);
        // Act
        final result = await repository.getCurrentUser();
        // Assert
        expect(result, const Right(tNullUser));
        verify(() => mockRemoteDataSource.getCurrentUser());
      },
    );

    test(
      'should return AuthFailure when remoteDataSource throws AuthException',
      () async {
        // Arrange
        final tException = AuthException(message: 'Not authenticated');
        when(() => mockRemoteDataSource.getCurrentUser()).thenThrow(tException);
        // Act
        final result = await repository.getCurrentUser();
        // Assert
        expect(result, Left(AuthFailure(message: tException.message)));
        verify(() => mockRemoteDataSource.getCurrentUser());
      },
    );

    test('should return UnexpectedFailure for other exceptions', () async {
      // Arrange
      final tException = Exception('Error fetching user');
      when(() => mockRemoteDataSource.getCurrentUser()).thenThrow(tException);
      // Act
      final result = await repository.getCurrentUser();
      // Assert
      expect(result, Left(UnexpectedFailure(message: tException.toString())));
      verify(() => mockRemoteDataSource.getCurrentUser());
    });

    // Note: The current implementation doesn't check network connectivity for getCurrentUser.
    // If it should, add offline tests.
  });
}
