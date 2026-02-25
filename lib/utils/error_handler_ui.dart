import 'package:flutter/material.dart';

/// Error Handler UI
/// Provides consistent error UI dialogs and snackbars across the app
class ErrorHandlerUI {
  /// Show error dialog with title, message, and action button
  static Future<void> showErrorDialog(
    BuildContext context, {
    required String title,
    required String message,
    String actionLabel = 'OK',
    VoidCallback? onAction,
  }) async {
    if (!context.mounted) return;

    return showDialog<void>(
      context: context,
      builder:
          (BuildContext context) => AlertDialog(
            title: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.red),
                const SizedBox(width: 12),
                Expanded(child: Text(title)),
              ],
            ),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  onAction?.call();
                },
                child: Text(actionLabel),
              ),
            ],
          ),
    );
  }

  /// Show retry dialog for network/API errors
  static Future<bool> showRetryDialog(
    BuildContext context, {
    required String title,
    required String message,
    String retryLabel = 'Retry',
    String cancelLabel = 'Cancel',
  }) async {
    if (!context.mounted) return false;

    final result = await showDialog<bool>(
      context: context,
      builder:
          (BuildContext context) => AlertDialog(
            title: Row(
              children: [
                const Icon(Icons.cloud_off_outlined, color: Colors.orange),
                const SizedBox(width: 12),
                Expanded(child: Text(title)),
              ],
            ),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(cancelLabel),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(retryLabel),
              ),
            ],
          ),
    );

    return result ?? false;
  }

  /// Show timeout error dialog
  static Future<void> showTimeoutDialog(
    BuildContext context, {
    String title = 'Request Timeout',
    String message =
        'The request took too long. Please check your internet connection and try again.',
    VoidCallback? onRetry,
  }) async {
    await showErrorDialog(
      context,
      title: title,
      message: message,
      actionLabel: onRetry != null ? 'Retry' : 'OK',
      onAction: onRetry,
    );
  }

  /// Show authentication error dialog (redirect to login)
  static Future<void> showAuthErrorDialog(
    BuildContext context, {
    required VoidCallback onLoginRedirect,
    String title = 'Authentication Failed',
    String message = 'Your session has expired. Please login again.',
  }) async {
    if (!context.mounted) return;

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder:
          (BuildContext context) => AlertDialog(
            title: Row(
              children: [
                const Icon(Icons.lock_outline, color: Colors.red),
                const SizedBox(width: 12),
                Expanded(child: Text(title)),
              ],
            ),
            content: Text(message),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  onLoginRedirect();
                },
                child: const Text('Go to Login'),
              ),
            ],
          ),
    );
  }

  /// Show validation error dialog
  static Future<void> showValidationDialog(
    BuildContext context, {
    required String title,
    required List<String> errors,
  }) async {
    if (!context.mounted) return;

    return showDialog<void>(
      context: context,
      builder:
          (BuildContext context) => AlertDialog(
            title: Row(
              children: [
                const Icon(Icons.warning_amber_outlined, color: Colors.amber),
                const SizedBox(width: 12),
                Expanded(child: Text(title)),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children:
                    errors
                        .map(
                          (error) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  '• ',
                                  style: TextStyle(color: Colors.amber),
                                ),
                                Expanded(child: Text(error)),
                              ],
                            ),
                          ),
                        )
                        .toList(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  /// Show success snackbar
  static void showSuccessSnackbar(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 2),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
        duration: duration,
      ),
    );
  }

  /// Show error snackbar
  static void showErrorSnackbar(
    BuildContext context,
    String message, {
    VoidCallback? onRetry,
    Duration duration = const Duration(seconds: 3),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        duration: duration,
        action:
            onRetry != null
                ? SnackBarAction(
                  label: 'Retry',
                  textColor: Colors.white,
                  onPressed: onRetry,
                )
                : null,
      ),
    );
  }

  /// Show warning snackbar
  static void showWarningSnackbar(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.orange,
        duration: duration,
      ),
    );
  }

  /// Show info snackbar
  static void showInfoSnackbar(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 2),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.blue,
        duration: duration,
      ),
    );
  }

  /// Parse API error and show appropriate dialog
  static Future<void> handleApiError(
    BuildContext context,
    dynamic error, {
    VoidCallback? onRetry,
  }) async {
    String title = 'Error';
    String message = 'An unexpected error occurred. Please try again.';

    if (error is TimeoutException) {
      await showTimeoutDialog(context, onRetry: onRetry);
      return;
    }

    if (error is FormatException) {
      title = 'Invalid Data';
      message = 'The server returned invalid data. Please try again.';
    } else if (error.toString().contains('401')) {
      title = 'Unauthorized';
      message = 'Your session has expired. Please login again.';
    } else if (error.toString().contains('403')) {
      title = 'Forbidden';
      message = 'You do not have permission to perform this action.';
    } else if (error.toString().contains('404')) {
      title = 'Not Found';
      message = 'The requested resource was not found.';
    } else if (error.toString().contains('500')) {
      title = 'Server Error';
      message = 'The server encountered an error. Please try again later.';
    } else if (error.toString().contains('Network')) {
      title = 'Network Error';
      message = 'Unable to connect. Please check your internet connection.';
    }

    await showErrorDialog(
      context,
      title: title,
      message: message,
      actionLabel: onRetry != null ? 'Retry' : 'OK',
      onAction: onRetry,
    );
  }
}

class TimeoutException implements Exception {
  final String message;

  TimeoutException(this.message);

  @override
  String toString() => message;
}
