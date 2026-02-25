import 'api_service.dart';

/// Employee Authentication & Profile API Service
///
/// Handles all employee-related API calls to the Next.js backend.
/// These are high-level wrappers around ApiService methods.
class EmployeeApiService {
  /// Register a new employee account with email
  ///
  /// [email] - Employee email address
  /// [password] - Account password
  /// [firstName] - First name
  /// [lastName] - Last name
  ///
  /// Returns: {id, email, firstName, lastName, token?}
  static Future<Map<String, dynamic>> registerWithEmail({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    try {
      final response = await ApiService.post(
        '/auth/employee/register-email',
        body: {
          'email': email,
          'password': password,
          'firstName': firstName,
          'lastName': lastName,
        },
      );
      return response as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  /// Register a new employee account with phone (OTP)
  ///
  /// [phone] - Employee phone number (with country code)
  /// [firstName] - First name
  /// [lastName] - Last name
  ///
  /// Returns: {phoneVerificationId?, message}
  static Future<Map<String, dynamic>> registerWithPhone({
    required String phone,
    required String firstName,
    required String lastName,
  }) async {
    try {
      final response = await ApiService.post(
        '/auth/employee/register-phone',
        body: {'phone': phone, 'firstName': firstName, 'lastName': lastName},
      );
      return response as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  /// Login with email and password
  ///
  /// [email] - Employee email
  /// [password] - Account password
  ///
  /// Returns: {id, email, firstName, lastName, token}
  static Future<Map<String, dynamic>> loginWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await ApiService.post(
        '/auth/employee/login-email',
        body: {'email': email, 'password': password},
      );
      return response as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  /// Send OTP to phone number for login/verification
  ///
  /// [phone] - Phone number to send OTP to
  ///
  /// Returns: {phoneVerificationId?, message}
  static Future<Map<String, dynamic>> sendLoginOtp({
    required String phone,
  }) async {
    try {
      final response = await ApiService.post(
        '/auth/employee/send-otp',
        body: {'phone': phone},
      );
      return response as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  /// Verify OTP and login/register
  ///
  /// [phone] - Phone number that initiated OTP
  /// [otp] - 6-digit OTP code
  /// [phoneVerificationId] - Verification ID from send-otp (if available)
  ///
  /// Returns: {id, phone, firstName?, lastName?, token}
  static Future<Map<String, dynamic>> verifyOtp({
    required String phone,
    required String otp,
    String? phoneVerificationId,
  }) async {
    try {
      final response = await ApiService.post(
        '/auth/employee/verify-otp',
        body: {
          'phone': phone,
          'otp': otp,
          if (phoneVerificationId != null)
            'phoneVerificationId': phoneVerificationId,
        },
      );
      return response as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  /// Logout the current employee
  ///
  /// [authToken] - Firebase/JWT token from session
  ///
  /// Returns: {message}
  static Future<Map<String, dynamic>> logout({
    required String authToken,
  }) async {
    try {
      final response = await ApiService.post(
        '/auth/employee/logout',
        authToken: authToken,
      );
      return response as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  /// Fetch current employee profile
  ///
  /// [authToken] - Firebase/JWT token from session
  ///
  /// Returns: {id, email, phone, firstName, lastName, profilePicture?, bio?, ...}
  static Future<Map<String, dynamic>> getProfile({
    required String authToken,
  }) async {
    try {
      final response = await ApiService.get(
        '/employee/profile',
        authToken: authToken,
      );
      return response as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  /// Update employee profile
  ///
  /// [authToken] - Firebase/JWT token from session
  /// [body] - Partial profile data to update (firstName, lastName, bio, profilePicture, etc.)
  ///
  /// Returns: {id, email, phone, firstName, lastName, ...updated fields}
  static Future<Map<String, dynamic>> updateProfile({
    required String authToken,
    required Map<String, dynamic> body,
  }) async {
    try {
      final response = await ApiService.put(
        '/employee/profile',
        body: body,
        authToken: authToken,
      );
      return response as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  /// Upload profile picture
  ///
  /// [authToken] - Firebase/JWT token from session
  /// [fileName] - Name of the file
  /// [filePath] - Local path to the image file
  ///
  /// Returns: {profilePictureUrl}
  ///
  /// NOTE: This is a multi-part upload. Will be handled separately
  /// when we implement file upload in a future task.
  static Future<Map<String, dynamic>> uploadProfilePicture({
    required String authToken,
    required String fileName,
    required String filePath,
  }) async {
    try {
      // TODO: Implement multipart form data upload
      // For now, this is a placeholder
      throw ApiException(message: 'Profile picture upload not yet implemented');
    } catch (e) {
      rethrow;
    }
  }

  /// Refresh authentication token (when current token is about to expire)
  ///
  /// [refreshToken] - Refresh token from previous login
  ///
  /// Returns: {token, expiresIn}
  static Future<Map<String, dynamic>> refreshToken({
    required String refreshToken,
  }) async {
    try {
      final response = await ApiService.post(
        '/auth/employee/refresh-token',
        body: {'refreshToken': refreshToken},
      );
      return response as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }
}
