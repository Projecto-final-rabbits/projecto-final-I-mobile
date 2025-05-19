import 'package:shared_preferences/shared_preferences.dart';

import '../../features/auth/domain/entities/user.dart';

class UserPreferencesService {
  static const String _userRoleKey = 'user_role';

  // Save user role to shared preferences
  Future<void> saveUserRole(UserRole role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userRoleKey, role.name);
  }

  // Get user role from shared preferences
  Future<UserRole?> getUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    final roleString = prefs.getString(_userRoleKey);

    if (roleString == null) {
      return null;
    }

    return roleString == UserRole.seller.name
        ? UserRole.seller
        : UserRole.client;
  }

  // Clear user role from shared preferences
  Future<void> clearUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userRoleKey);
  }
}
