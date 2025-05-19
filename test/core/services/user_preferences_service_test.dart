import 'package:cpp_app/core/services/user_preferences_service.dart';
import 'package:cpp_app/features/auth/domain/entities/user.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late UserPreferencesService userPreferencesService;

  setUp(() {
    userPreferencesService = UserPreferencesService();
  });

  group('UserPreferencesService', () {
    test('saveUserRole should store user role in shared preferences', () async {
      // Arrange
      SharedPreferences.setMockInitialValues({});

      // Act
      await userPreferencesService.saveUserRole(UserRole.seller);

      // Get the saved value
      final prefs = await SharedPreferences.getInstance();
      final savedRole = prefs.getString('user_role');

      // Assert
      expect(savedRole, UserRole.seller.name);
    });

    test(
      'getUserRole should return stored role from shared preferences',
      () async {
        // Arrange
        SharedPreferences.setMockInitialValues({
          'user_role': UserRole.seller.name,
        });

        // Act
        final result = await userPreferencesService.getUserRole();

        // Assert
        expect(result, UserRole.seller);
      },
    );

    test(
      'getUserRole should return client role if saved role is client',
      () async {
        // Arrange
        SharedPreferences.setMockInitialValues({
          'user_role': UserRole.client.name,
        });

        // Act
        final result = await userPreferencesService.getUserRole();

        // Assert
        expect(result, UserRole.client);
      },
    );

    test('getUserRole should return null if no role is stored', () async {
      // Arrange
      SharedPreferences.setMockInitialValues({});

      // Act
      final result = await userPreferencesService.getUserRole();

      // Assert
      expect(result, null);
    });

    test('clearUserRole should remove role from shared preferences', () async {
      // Arrange
      SharedPreferences.setMockInitialValues({
        'user_role': UserRole.seller.name,
      });

      // Act
      await userPreferencesService.clearUserRole();

      // Get the saved value
      final prefs = await SharedPreferences.getInstance();
      final savedRole = prefs.getString('user_role');

      // Assert
      expect(savedRole, null);
    });
  });
}
