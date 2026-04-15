import 'package:shared_preferences/shared_preferences.dart';

/// Session Service - Manages authentication state and tokens
/// Provides single source of truth for auth data across the app
class SessionService {
  // Storage keys
  static const String _authTokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _isLoggedInKey = 'isLoggedIn';
  static const String _roleKey = 'role';
  static const String _userIdKey = 'user_id';
  static const String _userEmailKey = 'user_email';

  /// Save authentication token (Firebase/JWT)
  ///
  /// [token] - Access token from login/register response
  /// [refreshToken] - Optional refresh token for token renewal
  static Future<void> saveAuthToken(
    String token, {
    String? refreshToken,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_authTokenKey, token);
    if (refreshToken != null && refreshToken.isNotEmpty) {
      await prefs.setString(_refreshTokenKey, refreshToken);
    }
  }

  /// Get stored authentication token
  ///
  /// Returns: Access token or null if not set
  static Future<String?> getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_authTokenKey);
  }

  /// Get stored refresh token
  ///
  /// Returns: Refresh token or null if not set
  static Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_refreshTokenKey);
  }

  /// Check if user is authenticated
  ///
  /// Returns: true if auth token exists, false otherwise
  static Future<bool> isAuthenticated() async {
    final token = await getAuthToken();
    return token != null && token.isNotEmpty;
  }

  /// Save complete session after login/register
  ///
  /// [role] - 'employee' or 'employer'
  /// [userId] - User ID from backend
  /// [email] - User email
  /// [authToken] - Access token
  /// [refreshToken] - Optional refresh token
  static Future<void> saveSession({
    required String role,
    required String userId,
    required String email,
    required String authToken,
    String? refreshToken,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isLoggedInKey, true);
    await prefs.setString(_roleKey, role);
    await prefs.setString(_userIdKey, userId);
    await prefs.setString(_userEmailKey, email);
    await prefs.setString(_authTokenKey, authToken);
    if (refreshToken != null && refreshToken.isNotEmpty) {
      await prefs.setString(_refreshTokenKey, refreshToken);
    }
  }

  /// Get stored user role
  ///
  /// Returns: 'employee', 'employer', or null if not set
  static Future<String?> getRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_roleKey);
  }

  /// Get stored user ID
  ///
  /// Returns: User ID or null if not set
  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userIdKey);
  }

  /// Get stored user email
  ///
  /// Returns: Email or null if not set
  static Future<String?> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userEmailKey);
  }

  /// Update auth token (when refreshing)
  ///
  /// [newToken] - New access token
  static Future<void> updateAuthToken(String newToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_authTokenKey, newToken);
  }

  /// Clear all authentication data (logout)
  ///
  /// Removes: auth token, refresh token, user ID, email, role, login status
  static Future<void> clearAuth() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_authTokenKey);
    await prefs.remove(_refreshTokenKey);
    await prefs.remove(_userIdKey);
    await prefs.remove(_userEmailKey);
    await prefs.remove(_roleKey);
    await prefs.setBool(_isLoggedInKey, false);
  }

  /// Clear entire session (legacy method, kept for compatibility)
  @Deprecated('Use clearAuth instead')
  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
