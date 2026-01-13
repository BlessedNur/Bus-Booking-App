import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';
  static const String _onboardingKey = 'onboarding_completed';
  static const String _sessionTimestampKey = 'session_timestamp';
  static const int _sessionDurationDays = 2; // Session expires after 2 days

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    // Save session timestamp when token is saved
    await prefs.setInt(_sessionTimestampKey, DateTime.now().millisecondsSinceEpoch);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_sessionTimestampKey);
  }

  /// Check if user has a valid session (not expired)
  static Future<bool> hasValidSession() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    final timestamp = prefs.getInt(_sessionTimestampKey);
    
    // No token means no session
    if (token == null || timestamp == null) {
      return false;
    }
    
    // Check if session has expired (2 days)
    final sessionTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final now = DateTime.now();
    final difference = now.difference(sessionTime);
    
    if (difference.inDays >= _sessionDurationDays) {
      // Session expired, clear token
      await removeToken();
      return false;
    }
    
    return true;
  }

  /// Get remaining session time in hours
  static Future<int> getRemainingSessionHours() async {
    final prefs = await SharedPreferences.getInstance();
    final timestamp = prefs.getInt(_sessionTimestampKey);
    
    if (timestamp == null) {
      return 0;
    }
    
    final sessionTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final now = DateTime.now();
    final difference = now.difference(sessionTime);
    final remaining = Duration(days: _sessionDurationDays) - difference;
    
    return remaining.inHours > 0 ? remaining.inHours : 0;
  }

  static Future<void> saveUser(String userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, userData);
  }

  static Future<String?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userKey);
  }

  static Future<void> removeUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
  }

  static Future<void> setOnboardingCompleted(bool completed) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingKey, completed);
  }

  static Future<bool> isOnboardingCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_onboardingKey) ?? false;
  }

  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
