import 'package:cpp_app/core/error/failures.dart';
import 'package:cpp_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:cpp_app/features/auth/domain/usecases/sign_out.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// Mock AuthRepository
class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late SignOut usecase;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    usecase = SignOut(mockAuthRepository);
    // Register fallback value for Either<Failure, void>
    registerFallbackValue(
      const Left<Failure, void>(ServerFailure(message: 'Logout failed')),
    );
    registerFallbackValue(const Right<Failure, void>(null));
  });

  group('SignOut', () {
    test('should call signOut on the repository', () async {
      // Arrange
      when(
        () => mockAuthRepository.signOut(),
      ).thenAnswer((_) async => const Right(null)); // Represents success (void)

      // Act
      final result = await usecase();

      // Assert
      expect(result, const Right(null));
      verify(() => mockAuthRepository.signOut());
      verifyNoMoreInteractions(mockAuthRepository);
    });

    test('should return a Failure when signOut fails', () async {
      // Arrange
      const tFailure = ServerFailure(message: 'Sign out error');
      when(
        () => mockAuthRepository.signOut(),
      ).thenAnswer((_) async => const Left(tFailure));

      // Act
      final result = await usecase();

      // Assert
      expect(result, const Left(tFailure));
      verify(() => mockAuthRepository.signOut());
      verifyNoMoreInteractions(mockAuthRepository);
    });
  });
}
