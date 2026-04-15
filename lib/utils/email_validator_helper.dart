class EmailValidatorHelper {
  // Standard strict regex for email formatting (ensures a proper TLD like .com, .org, etc.)
  static final RegExp _emailRegExp = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  // List of known disposable/fake email domains
  static const List<String> _disposableDomains = [
    '10minutemail.com',
    'mailinator.com',
    'temp-mail.org',
    'guerrillamail.com',
    'yopmail.com',
    'throwawaymail.com',
    'maildrop.cc',
    'getairmail.com',
    'sharklasers.com',
    'tempmail.com',
    'dispostable.com',
  ];

  // List of consumer/free email providers
  static const List<String> _freeEmailProviders = [
    'gmail.com',
    'yahoo.com',
    'hotmail.com',
    'outlook.com',
    'aol.com',
    'icloud.com',
    'yandex.com',
    'mail.com',
    'live.com',
    'msn.com',
    'proton.me',
    'protonmail.com'
  ];

  /// Validates standard user/employee emails.
  /// Checks format and blocks temporary/disposable emails.
  static String? validateEmployeeEmail(String email) {
    if (email.trim().isEmpty) return 'Please enter your email.';

    final normalized = email.trim().toLowerCase();

    if (!_emailRegExp.hasMatch(normalized)) {
      return 'Please enter a valid email address (e.g., name@domain.com, .org, etc.)';
    }

    final domain = normalized.split('@').last;

    if (_disposableDomains.contains(domain)) {
      return 'Disposable or temporary email addresses are not allowed.';
    }

    return null; // Email is valid
  }

  /// Validates business/employer emails.
  /// Checks format, blocks disposable emails, AND blocks standard consumer providers.
  static String? validateEmployerEmail(String email) {
    final basicError = validateEmployeeEmail(email);
    if (basicError != null) return basicError;

    final normalized = email.trim().toLowerCase();
    final domain = normalized.split('@').last;

    if (_freeEmailProviders.contains(domain)) {
      return 'Employers must register with a valid business email domain (e.g., @company.com, .org). Free providers are not allowed.';
    }

    return null; // Valid business email
  }
}
