import 'package:cpp_app/core/error/failures.dart';
import 'package:cpp_app/features/auth/domain/entities/user.dart';
import 'package:cpp_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:cpp_app/features/auth/domain/usecases/sign_up_seller.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// Mock AuthRepository
class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late SignUpSeller usecase;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    usecase = SignUpSeller(mockAuthRepository);
    // Register fallback values if needed by mocktail
    registerFallbackValue(
      const Left<Failure, User>(ServerFailure(message: 'Fallback failure')),
    );
    registerFallbackValue(
      const Right<Failure, User>(
        User(
          id: 'fallback',
          email: 'fallback@example.com',
          role: UserRole.seller,
        ),
      ),
    );
  });

  // Test data
  const tEmail = 'seller@example.com';
  const tPassword = 'password123';
  const tName = 'Test Seller';
  const tZone = 'North Zone';
  const tPhone = '555-5678';
  const tUser = User(
    id: 'seller1',
    email: tEmail,
    role: UserRole.seller,
    name: tName,
    zone: tZone,
    phone: tPhone,
  );
  const tParams = SignUpSellerParams(
    email: tEmail,
    password: tPassword,
    name: tName,
    zone: tZone,
    phone: tPhone,
  );

  group('SignUpSeller', () {
    test('should sign up seller using the repository', () async {
      // Arrange
      when(
        () =>
            mockAuthRepository.signUpSeller(any(), any(), any(), any(), any()),
      ).thenAnswer((_) async => const Right(tUser));

      // Act
      final result = await usecase(tParams);

      // Assert
      expect(result, const Right(tUser));
      verify(
        () => mockAuthRepository.signUpSeller(
          tEmail,
          tPassword,
          tName,
          tZone,
          tPhone,
        ),
      );
      verifyNoMoreInteractions(mockAuthRepository);
    });

    test('should return a Failure when the repository fails', () async {
      // Arrange
      const tFailure = ServerFailure(message: 'Sign up failed');
      when(
        () =>
            mockAuthRepository.signUpSeller(any(), any(), any(), any(), any()),
      ).thenAnswer((_) async => const Left(tFailure));

      // Act
      final result = await usecase(tParams);

      // Assert
      expect(result, const Left(tFailure));
      verify(
        () => mockAuthRepository.signUpSeller(
          tEmail,
          tPassword,
          tName,
          tZone,
          tPhone,
        ),
      );
      verifyNoMoreInteractions(mockAuthRepository);
    });
  });
}
