import 'package:shared_preferences/shared_preferences.dart';

/// Manages authentication-related user preferences like "stay logged in"
class AuthSettings {
  AuthSettings._();

  static const String _stayLoggedInKey = 'auth_stay_logged_in';

  /// Save the "stay logged in" preference
  /// [stayLoggedIn] - true if user wants to remain logged in, false otherwise
  static Future<void> saveStayLoggedIn(bool stayLoggedIn) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_stayLoggedInKey, stayLoggedIn);
  }

  /// Load the "stay logged in" preference
  /// Returns false by default (opt-in model - user must explicitly check)
  static Future<bool> loadStayLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_stayLoggedInKey) ?? false;
  }

  /// Clear the "stay logged in" preference (e.g., on logout)
  static Future<void> clearStayLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_stayLoggedInKey);
  }
}
