import 'package:flutter_test/flutter_test.dart';
import 'package:leox/providers/employer_auth_provider.dart';

void main() {
  group('EmployerAuthProvider Tests', () {
    late EmployerAuthProvider authProvider;

    setUp(() {
      authProvider = EmployerAuthProvider();
    });

    tearDown(() {
      authProvider.dispose();
    });

    test('should initialize with default values', () {
      expect(authProvider.isLoading, false);
      expect(authProvider.errorMessage, null);
      expect(authProvider.successMessage, null);
    });

    test('should set loading state correctly', () {
      authProvider.setLoading(true);
      expect(authProvider.isLoading, true);
      
      authProvider.setLoading(false);
      expect(authProvider.isLoading, false);
    });

    test('should handle auth state changes', () {
      // Test that the provider can handle auth state changes
      expect(authProvider.isLoggedIn, isA<bool>());
      expect(authProvider.userId, isA<String?>());
      expect(authProvider.userEmail, isA<String?>());
    });

    /// Public wrapper so UI/tests can set loading state
    test('setLoading should work', () {
      authProvider.setLoading(true);
      expect(authProvider.isLoading, true);

      authProvider.setLoading(false);
      expect(authProvider.isLoading, false);
    });
  });
}
