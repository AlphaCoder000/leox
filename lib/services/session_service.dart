import 'package:shared_preferences/shared_preferences.dart';

/// Session Service - Manages authentication state and tokens
/// Provides single source of truth for auth data across the app with in-memory caching
class SessionService {
  // Storage keys
  static const String _authTokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _isLoggedInKey = 'isLoggedIn';
  static const String _roleKey = 'role';
  static const String _userIdKey = 'user_id';
  static const String _userEmailKey = 'user_email';
  static const String _targetRoleKey = 'target_role';

  // In-Memory Cache to prevent asynchronous SharedPreferences race conditions during login/logout
  static String? _cachedRole;
  static String? _cachedTargetRole;
  static String? _cachedUserId;
  static String? _cachedUserEmail;
  static String? _cachedAuthToken;
  static String? _cachedRefreshToken;

  /// Save target login role
  static Future<void> saveTargetRole(String role) async {
    _cachedTargetRole = role;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_targetRoleKey, role);
  }

  /// Get target login role
  static Future<String?> getTargetRole() async {
    if (_cachedTargetRole != null) return _cachedTargetRole;
    final prefs = await SharedPreferences.getInstance();
    _cachedTargetRole = prefs.getString(_targetRoleKey);
    return _cachedTargetRole;
  }

  /// Clear target login role
  static Future<void> clearTargetRole() async {
    _cachedTargetRole = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_targetRoleKey);
  }

  /// Save active role only
  static Future<void> saveRoleOnly(String role) async {
    _cachedRole = role;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_roleKey, role);
  }

  /// Save authentication token (Firebase/JWT)
  static Future<void> saveAuthToken(
    String token, {
    String? refreshToken,
  }) async {
    _cachedAuthToken = token;
    if (refreshToken != null && refreshToken.isNotEmpty) {
      _cachedRefreshToken = refreshToken;
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_authTokenKey, token);
    if (refreshToken != null && refreshToken.isNotEmpty) {
      await prefs.setString(_refreshTokenKey, refreshToken);
    }
  }

  /// Get stored authentication token
  static Future<String?> getAuthToken() async {
    if (_cachedAuthToken != null) return _cachedAuthToken;
    final prefs = await SharedPreferences.getInstance();
    _cachedAuthToken = prefs.getString(_authTokenKey);
    return _cachedAuthToken;
  }

  /// Get stored refresh token
  static Future<String?> getRefreshToken() async {
    if (_cachedRefreshToken != null) return _cachedRefreshToken;
    final prefs = await SharedPreferences.getInstance();
    _cachedRefreshToken = prefs.getString(_refreshTokenKey);
    return _cachedRefreshToken;
  }

  /// Check if user is authenticated
  static Future<bool> isAuthenticated() async {
    final token = await getAuthToken();
    return token != null && token.isNotEmpty;
  }

  /// Save complete session after login/register
  static Future<void> saveSession({
    required String role,
    required String userId,
    required String email,
    required String authToken,
    String? refreshToken,
  }) async {
    _cachedRole = role;
    _cachedUserId = userId;
    _cachedUserEmail = email;
    _cachedAuthToken = authToken;
    if (refreshToken != null && refreshToken.isNotEmpty) {
      _cachedRefreshToken = refreshToken;
    }

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
  static Future<String?> getRole() async {
    if (_cachedRole != null) return _cachedRole;
    final prefs = await SharedPreferences.getInstance();
    _cachedRole = prefs.getString(_roleKey);
    return _cachedRole;
  }

  /// Get stored user ID
  static Future<String?> getUserId() async {
    if (_cachedUserId != null) return _cachedUserId;
    final prefs = await SharedPreferences.getInstance();
    _cachedUserId = prefs.getString(_userIdKey);
    return _cachedUserId;
  }

  /// Get stored user email
  static Future<String?> getUserEmail() async {
    if (_cachedUserEmail != null) return _cachedUserEmail;
    final prefs = await SharedPreferences.getInstance();
    _cachedUserEmail = prefs.getString(_userEmailKey);
    return _cachedUserEmail;
  }

  /// Update auth token (when refreshing)
  static Future<void> updateAuthToken(String newToken) async {
    _cachedAuthToken = newToken;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_authTokenKey, newToken);
  }

  /// Clear all authentication data (logout)
  static Future<void> clearAuth() async {
    _cachedRole = null;
    _cachedTargetRole = null;
    _cachedUserId = null;
    _cachedUserEmail = null;
    _cachedAuthToken = null;
    _cachedRefreshToken = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_authTokenKey);
    await prefs.remove(_refreshTokenKey);
    await prefs.remove(_userIdKey);
    await prefs.remove(_userEmailKey);
    await prefs.remove(_roleKey);
    await prefs.remove(_targetRoleKey);
    await prefs.setBool(_isLoggedInKey, false);
  }

  /// Clear entire session (legacy method, kept for compatibility)
  @Deprecated('Use clearAuth instead')
  static Future<void> clearSession() async {
    _cachedRole = null;
    _cachedTargetRole = null;
    _cachedUserId = null;
    _cachedUserEmail = null;
    _cachedAuthToken = null;
    _cachedRefreshToken = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
