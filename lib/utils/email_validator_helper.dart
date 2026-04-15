class EmailValidatorHelper {
  // Standard strict regex for email formatting (ensures a proper TLD like .com, .org, etc.)
  static final RegExp _emailRegExp = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  /// Validates standard user/employee emails.
  /// Checks format, but no longer blocks domains.
  static String? validateEmployeeEmail(String email) {
    if (email.trim().isEmpty) return 'Please enter your email.';

    final normalized = email.trim().toLowerCase();

    if (!_emailRegExp.hasMatch(normalized)) {
      return 'Please enter a valid email address (e.g., name@domain.com, .org, etc.)';
    }

    return null; // Email is valid
  }

  /// Validates business/employer emails.
  /// Checks format, but no longer blocks domains.
  static String? validateEmployerEmail(String email) {
    final basicError = validateEmployeeEmail(email);
    if (basicError != null) return basicError;

    return null; // Valid business email
  }
}
