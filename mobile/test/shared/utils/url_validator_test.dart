/// URL Validator Tests
///
/// Testing URL validation and normalization utility.
/// Following TDD: Writing tests BEFORE implementation!
///
/// Test cases cover:
/// - Valid URLs (with/without protocol)
/// - Invalid URLs (malformed, not URLs at all)
/// - URL normalization (adding https:// when missing)

import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/shared/utils/url_validator.dart';

void main() {
  group('UrlValidator', () {
    /// Test #1: Validates correct URLs with protocols
    test('validates URLs with http:// protocol', () {
      // Arrange
      const url = 'http://example.com';

      // Act
      final result = UrlValidator.isValid(url);

      // Assert
      expect(result, true);
    });

    test('validates URLs with https:// protocol', () {
      // Arrange
      const url = 'https://example.com';

      // Act
      final result = UrlValidator.isValid(url);

      // Assert
      expect(result, true);
    });

    test('validates complex URLs with paths and query params', () {
      // Arrange
      const url = 'https://example.com/path/to/page?query=param&foo=bar';

      // Act
      final result = UrlValidator.isValid(url);

      // Assert
      expect(result, true);
    });

    /// Test #2: Validates URLs without protocol (common user input)
    test('validates URLs without protocol (example.com)', () {
      // Arrange
      const url = 'example.com';

      // Act
      final result = UrlValidator.isValid(url);

      // Assert: Should still be considered valid (we'll add protocol later)
      expect(result, true);
    });

    test('validates URLs without protocol but with www', () {
      // Arrange
      const url = 'www.example.com';

      // Act
      final result = UrlValidator.isValid(url);

      // Assert
      expect(result, true);
    });

    /// Test #3: Rejects invalid URLs
    test('rejects empty string', () {
      // Arrange
      const url = '';

      // Act
      final result = UrlValidator.isValid(url);

      // Assert
      expect(result, false);
    });

    test('rejects random text (not a URL)', () {
      // Arrange
      const url = 'not a url at all';

      // Act
      final result = UrlValidator.isValid(url);

      // Assert
      expect(result, false);
    });

    test('rejects malformed URLs', () {
      // Arrange
      const url = 'http://';

      // Act
      final result = UrlValidator.isValid(url);

      // Assert
      expect(result, false);
    });

    test('rejects invalid domain format', () {
      // Arrange
      const url = 'https://invalid..domain';

      // Act
      final result = UrlValidator.isValid(url);

      // Assert
      expect(result, false);
    });

    /// Test #4: URL Normalization (adds https:// if missing)
    test('normalizes URL without protocol by adding https://', () {
      // Arrange
      const url = 'example.com';

      // Act
      final result = UrlValidator.normalize(url);

      // Assert
      expect(result, 'https://example.com');
    });

    test('normalizes www URL without protocol by adding https://', () {
      // Arrange
      const url = 'www.example.com';

      // Act
      final result = UrlValidator.normalize(url);

      // Assert
      expect(result, 'https://www.example.com');
    });

    test('does not modify URL that already has protocol', () {
      // Arrange
      const url = 'https://example.com';

      // Act
      final result = UrlValidator.normalize(url);

      // Assert
      expect(result, 'https://example.com');
    });

    test('preserves http:// protocol if provided', () {
      // Arrange
      const url = 'http://example.com';

      // Act
      final result = UrlValidator.normalize(url);

      // Assert
      expect(result, 'http://example.com');
    });

    test('normalizes complex URL without protocol', () {
      // Arrange
      const url = 'example.com/path?query=value';

      // Act
      final result = UrlValidator.normalize(url);

      // Assert
      expect(result, 'https://example.com/path?query=value');
    });

    /// Test #5: Edge cases
    test('validates localhost URLs', () {
      // Arrange
      const url = 'http://localhost:3000';

      // Act
      final result = UrlValidator.isValid(url);

      // Assert
      expect(result, true);
    });

    test('validates IP address URLs', () {
      // Arrange
      const url = 'http://192.168.1.1:8080';

      // Act
      final result = UrlValidator.isValid(url);

      // Assert
      expect(result, true);
    });
  });
}

/// 🎓 Learning Summary: URL Validation
///
/// **What Makes a Valid URL?**
/// 1. **Protocol:** http:// or https:// (optional for user input)
/// 2. **Domain:** example.com, www.example.com
/// 3. **Path:** /path/to/page (optional)
/// 4. **Query:** ?query=param (optional)
///
/// **Why Normalize URLs?**
/// Users often paste URLs without the protocol:
/// - "example.com" instead of "https://example.com"
/// - We normalize by adding "https://" automatically
/// - This makes the URL work with HTTP clients and browsers
///
/// **Validation Strategy:**
/// - Use regex pattern matching
/// - Check for valid domain format
/// - Allow URLs with/without protocol
/// - Reject empty strings and random text
///
/// **Next:**
/// Run these tests - they will FAIL (🔴 RED) because the
/// UrlValidator class doesn't exist yet. That's TDD!
/// Then we'll implement the validator to make them pass (🟢 GREEN).
