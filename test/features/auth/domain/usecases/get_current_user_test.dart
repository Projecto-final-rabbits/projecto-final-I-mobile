import 'package:cpp_app/features/auth/domain/entities/user.dart'; // Assuming User entity exists
import 'package:cpp_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:cpp_app/features/auth/domain/usecases/get_current_user.dart';
import 'package:dartz/dartz.dart'; // For Either
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// Mock AuthRepository
class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late GetCurrentUser usecase;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    usecase = GetCurrentUser(mockAuthRepository);
  });

  group('GetCurrentUser', () {
    // Define a test user instance
    const tUser = User(
      id: 1,
      email: 'test@example.com',
      role: UserRole.client,
      uid: '1',
    );

    test('should get current user from the repository', () async {
      // Arrange
      when(
        () => mockAuthRepository.getCurrentUser(),
      ).thenAnswer((_) async => const Right(tUser));

      // Act
      final result = await usecase();

      // Assert
      expect(result, const Right(tUser));
      verify(() => mockAuthRepository.getCurrentUser());
      verifyNoMoreInteractions(mockAuthRepository);
    });

    test('should return null when repository returns null', () async {
      // Arrange
      when(() => mockAuthRepository.getCurrentUser()).thenAnswer(
        (_) async => const Right(null),
      ); // Assuming repository can return null user if not logged in

      // Act
      final result = await usecase();

      // Assert
      expect(result, const Right(null));
      verify(() => mockAuthRepository.getCurrentUser());
      verifyNoMoreInteractions(mockAuthRepository);
    });

    // TODO: Add test for Failure case if repository throws/returns Failure
  });
}
