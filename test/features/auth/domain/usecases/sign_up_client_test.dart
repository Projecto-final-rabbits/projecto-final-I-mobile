import 'package:cpp_app/core/error/failures.dart';
import 'package:cpp_app/features/auth/domain/entities/user.dart';
import 'package:cpp_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:cpp_app/features/auth/domain/usecases/sign_up_client.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// Mock AuthRepository
class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late SignUpClient usecase;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    usecase = SignUpClient(mockAuthRepository);
    // Register fallback values if needed by mocktail
    registerFallbackValue(
      const Left<Failure, User>(ServerFailure(message: 'Fallback failure')),
    );
    registerFallbackValue(
      const Right<Failure, User>(
        User(
          id: 'fallback',
          email: 'fallback@example.com',
          role: UserRole.client,
        ),
      ),
    );
  });

  // Test data
  const tEmail = 'client@example.com';
  const tPassword = 'password123';
  const tName = 'Test Client';
  const tClientType = 'Individual';
  const tAddress = '123 Main St';
  const tPhone = '555-1234';
  const tUser = User(
    id: 'client1',
    email: tEmail,
    role: UserRole.client,
    name: tName,
    clientType: tClientType,
    address: tAddress,
    phone: tPhone,
  );
  const tParams = SignUpClientParams(
    email: tEmail,
    password: tPassword,
    name: tName,
    clientType: tClientType,
    address: tAddress,
    phone: tPhone,
  );

  group('SignUpClient', () {
    test('should sign up client using the repository', () async {
      // Arrange
      when(
        () => mockAuthRepository.signUpClient(
          any(),
          any(),
          any(),
          any(),
          any(),
          any(),
        ),
      ).thenAnswer((_) async => const Right(tUser));

      // Act
      final result = await usecase(tParams);

      // Assert
      expect(result, const Right(tUser));
      verify(
        () => mockAuthRepository.signUpClient(
          tEmail,
          tPassword,
          tName,
          tClientType,
          tAddress,
          tPhone,
        ),
      );
      verifyNoMoreInteractions(mockAuthRepository);
    });

    test('should return a Failure when the repository fails', () async {
      // Arrange
      const tFailure = ServerFailure(message: 'Sign up failed');
      when(
        () => mockAuthRepository.signUpClient(
          any(),
          any(),
          any(),
          any(),
          any(),
          any(),
        ),
      ).thenAnswer((_) async => const Left(tFailure));

      // Act
      final result = await usecase(tParams);

      // Assert
      expect(result, const Left(tFailure));
      verify(
        () => mockAuthRepository.signUpClient(
          tEmail,
          tPassword,
          tName,
          tClientType,
          tAddress,
          tPhone,
        ),
      );
      verifyNoMoreInteractions(mockAuthRepository);
    });
  });
}
