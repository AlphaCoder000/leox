import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Salary Split Logic Tests', () {
    test('should correctly parse salary string formatted as range with currency symbol', () {
      const storedSalary = '₹ 50000 - 80000';
      
      // Mimic the splitting logic in create_job_view.dart
      String foundCurrency = "₹";
      String remaining = storedSalary;
      for (final symbol in ['A\$', 'AED', 'SAR', 'KWD', 'Rp', '\$', '£', '€', '₹', '¥']) {
        if (remaining.startsWith(symbol)) {
          foundCurrency = symbol;
          remaining = remaining.substring(symbol.length).trim();
          break;
        }
      }
      
      final parts = remaining.split('-');
      expect(foundCurrency, '₹');
      expect(parts.length, 2);
      expect(parts[0].trim(), '50000');
      expect(parts[1].trim(), '80000');
    });

    test('should correctly handle stored salary string without dash', () {
      const storedSalary = '₹ 50000';
      
      String foundCurrency = "₹";
      String remaining = storedSalary;
      for (final symbol in ['A\$', 'AED', 'SAR', 'KWD', 'Rp', '\$', '£', '€', '₹', '¥']) {
        if (remaining.startsWith(symbol)) {
          foundCurrency = symbol;
          remaining = remaining.substring(symbol.length).trim();
          break;
        }
      }
      
      final parts = remaining.split('-');
      expect(foundCurrency, '₹');
      expect(parts[0].trim(), '50000');
      expect(parts.length, 1);
    });
  });

  group('Service Price Range Split Logic Tests', () {
    test('should correctly parse price range string with currency prefix', () {
      const storedPriceRange = '₹ 500 - 1500';
      
      // Mimic the splitting logic in mc_add_service_view.dart
      String foundCurrency = "₹";
      String remaining = storedPriceRange;
      for (final symbol in ['A\$', 'AED', 'SAR', 'KWD', 'Rp', '\$', '£', '€', '₹', '¥']) {
        if (remaining.startsWith(symbol)) {
          foundCurrency = symbol;
          remaining = remaining.substring(symbol.length).trim();
          break;
        }
      }
      
      final parts = remaining.split('-');
      expect(foundCurrency, '₹');
      expect(parts.length, 2);
      expect(parts[0].trim(), '500');
      expect(parts[1].trim(), '1500');
    });
  });
}
