import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

/// Exception class for API errors
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic originalError;

  ApiException({required this.message, this.statusCode, this.originalError});

  @override
  String toString() => 'ApiException: $message (Status: $statusCode)';
}

/// Base API Service for Next.js backend communication
class ApiService {
  /// Base URL for Next.js API (configure per environment)
  static String baseUrl = 'http://localhost:3000/api';

  /// Request timeout duration
  static const Duration timeoutDuration = Duration(minutes: 5);

  /// Set the base URL (call this once on app startup)
  static void setBaseUrl(String url) {
    baseUrl = url;
  }

  /// Common headers for all requests
  static Map<String, String> _getHeaders({String? authToken}) {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    // Add auth token if provided
    if (authToken != null && authToken.isNotEmpty) {
      headers['Authorization'] = 'Bearer $authToken';
    }

    return headers;
  }

  /// GET request
  ///
  /// [endpoint] - API endpoint (e.g., '/users/profile')
  /// [authToken] - Optional Firebase/JWT token for auth
  /// Returns decoded JSON response
  static Future<dynamic> get(String endpoint, {String? authToken}) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');
      final response = await http
          .get(url, headers: _getHeaders(authToken: authToken))
          .timeout(timeoutDuration);

      return _handleResponse(response);
    } on SocketException catch (e) {
      throw ApiException(
        message: 'Network error: ${e.message}',
        originalError: e,
      );
    } on TimeoutException {
      throw ApiException(
        message: 'Request timeout. Please check your connection.',
      );
    } catch (e) {
      throw ApiException(message: 'GET request failed: $e', originalError: e);
    }
  }

  /// POST request
  ///
  /// [endpoint] - API endpoint (e.g., '/auth/register')
  /// [body] - Request body (will be JSON encoded)
  /// [authToken] - Optional Firebase/JWT token for auth
  /// Returns decoded JSON response
  static Future<dynamic> post(
    String endpoint, {
    Map<String, dynamic>? body,
    String? authToken,
  }) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');
      final response = await http
          .post(
            url,
            headers: _getHeaders(authToken: authToken),
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(timeoutDuration);

      return _handleResponse(response);
    } on SocketException catch (e) {
      throw ApiException(
        message: 'Network error: ${e.message}',
        originalError: e,
      );
    } on TimeoutException {
      throw ApiException(
        message: 'Request timeout. Please check your connection.',
      );
    } catch (e) {
      throw ApiException(message: 'POST request failed: $e', originalError: e);
    }
  }

  /// PUT request
  ///
  /// [endpoint] - API endpoint (e.g., '/users/profile')
  /// [body] - Request body (will be JSON encoded)
  /// [authToken] - Optional Firebase/JWT token for auth
  /// Returns decoded JSON response
  static Future<dynamic> put(
    String endpoint, {
    Map<String, dynamic>? body,
    String? authToken,
  }) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');
      final response = await http
          .put(
            url,
            headers: _getHeaders(authToken: authToken),
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(timeoutDuration);

      return _handleResponse(response);
    } on SocketException catch (e) {
      throw ApiException(
        message: 'Network error: ${e.message}',
        originalError: e,
      );
    } on TimeoutException {
      throw ApiException(
        message: 'Request timeout. Please check your connection.',
      );
    } catch (e) {
      throw ApiException(message: 'PUT request failed: $e', originalError: e);
    }
  }

  /// DELETE request
  ///
  /// [endpoint] - API endpoint (e.g., '/users/123')
  /// [authToken] - Optional Firebase/JWT token for auth
  /// Returns decoded JSON response
  static Future<dynamic> delete(String endpoint, {String? authToken}) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');
      final response = await http
          .delete(url, headers: _getHeaders(authToken: authToken))
          .timeout(timeoutDuration);

      return _handleResponse(response);
    } on SocketException catch (e) {
      throw ApiException(
        message: 'Network error: ${e.message}',
        originalError: e,
      );
    } on TimeoutException {
      throw ApiException(
        message: 'Request timeout. Please check your connection.',
      );
    } catch (e) {
      throw ApiException(
        message: 'DELETE request failed: $e',
        originalError: e,
      );
    }
  }

  /// Handle HTTP response and return JSON or throw exception
  ///
  /// Interprets status codes:
  /// - 200-299: Success
  /// - 400: Bad request (validation error)
  /// - 401: Unauthorized
  /// - 403: Forbidden
  /// - 404: Not found
  /// - 500+: Server error
  static dynamic _handleResponse(http.Response response) {
    try {
      // Parse response body as JSON
      final jsonResponse = jsonDecode(response.body);

      // Success responses (2xx)
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return jsonResponse;
      }

      // Error responses with backend error message
      final errorMessage =
          jsonResponse['message'] ??
          jsonResponse['error'] ??
          'Unknown error occurred';

      switch (response.statusCode) {
        case 400:
          throw ApiException(
            message: 'Bad request: $errorMessage',
            statusCode: 400,
          );
        case 401:
          throw ApiException(
            message: 'Unauthorized: Please login again',
            statusCode: 401,
          );
        case 403:
          throw ApiException(
            message: 'Forbidden: You do not have access',
            statusCode: 403,
          );
        case 404:
          throw ApiException(
            message: 'Not found: $errorMessage',
            statusCode: 404,
          );
        case 500:
        case 502:
        case 503:
          throw ApiException(
            message: 'Server error: Please try again later',
            statusCode: response.statusCode,
          );
        default:
          throw ApiException(
            message: 'Error: $errorMessage',
            statusCode: response.statusCode,
          );
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      // Response body is not valid JSON
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {'success': true, 'statusCode': response.statusCode};
      }
      throw ApiException(
        message: 'Failed to parse response: $e',
        statusCode: response.statusCode,
      );
    }
  }
}
