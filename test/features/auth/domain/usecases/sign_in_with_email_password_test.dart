import 'package:cpp_app/core/error/failures.dart'; // Assuming a Failure class exists
import 'package:cpp_app/features/auth/domain/entities/user.dart';
import 'package:cpp_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:cpp_app/features/auth/domain/usecases/sign_in_with_email_password.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// Mock AuthRepository
class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late SignInWithEmailPassword usecase;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    usecase = SignInWithEmailPassword(mockAuthRepository);
    // Register fallback value for Either<Failure, User>
    // Provide the required message parameter for ServerFailure
    registerFallbackValue(
      const Left<Failure, User>(ServerFailure(message: 'Fallback failure')),
    );
    registerFallbackValue(
      const Right<Failure, User>(
        User(
          id: 1,
          email: 'fallback@example.com',
          role: UserRole.client,
          uid: '1',
        ),
      ),
    );
  });

  const tEmail = 'test@example.com';
  const tPassword = 'password123';
  const tUser = User(id: 1, email: tEmail, role: UserRole.client, uid: '1');
  const tParams = SignInWithEmailPasswordParams(
    email: tEmail,
    password: tPassword,
  );

  group('SignInWithEmailPassword', () {
    test(
      'should sign in user with email and password from the repository',
      () async {
        // Arrange
        when(
          () =>
              mockAuthRepository.signInWithEmailAndPassword(tEmail, tPassword),
        ).thenAnswer((_) async => const Right(tUser));

        // Act
        final result = await usecase(tParams);

        // Assert
        expect(result, const Right(tUser));
        verify(
          () =>
              mockAuthRepository.signInWithEmailAndPassword(tEmail, tPassword),
        );
        verifyNoMoreInteractions(mockAuthRepository);
      },
    );

    test('should return a Failure when the repository fails', () async {
      // Arrange
      // Corrected ServerFailure instantiation with the message parameter
      const tFailure = ServerFailure(message: 'Server error');
      when(
        () => mockAuthRepository.signInWithEmailAndPassword(tEmail, tPassword),
      ).thenAnswer((_) async => const Left(tFailure));

      // Act
      final result = await usecase(tParams);

      // Assert
      expect(result, const Left(tFailure));
      verify(
        () => mockAuthRepository.signInWithEmailAndPassword(tEmail, tPassword),
      );
      verifyNoMoreInteractions(mockAuthRepository);
    });
  });
}
