/// URL Validator Utility
///
/// Validates and normalizes URLs for the Add Link feature.
///
/// Real-World Analogy:
/// Think of this like a bouncer at a club - it checks if what you
/// gave it is actually a valid URL before letting it through.
/// It also helps users by adding "https://" if they forgot it.
///
/// Usage:
/// ```dart
/// // Validate a URL
/// if (UrlValidator.isValid('example.com')) {
///   print('Valid!');
/// }
///
/// // Normalize a URL (add https:// if missing)
/// final normalized = UrlValidator.normalize('example.com');
/// // Returns: 'https://example.com'
/// ```

class UrlValidator {
  /// Private constructor to prevent instantiation
  /// This is a utility class with only static methods
  UrlValidator._();

  /// Regular expression for URL validation
  ///
  /// What this regex matches:
  /// - Optional protocol: http:// or https://
  /// - Domain: example.com, www.example.com, localhost, IP addresses
  /// - Optional port: :3000, :8080
  /// - Optional path: /path/to/page
  /// - Optional query: ?query=param
  /// - Optional fragment: #section
  ///
  /// Examples that match:
  /// - https://example.com
  /// - http://www.example.com
  /// - example.com
  /// - example.com/path?query=value
  /// - localhost:3000
  /// - 192.168.1.1:8080
  static final RegExp _urlRegex = RegExp(
    r'^(?:'
    r'(?:https?:\/\/)?' // Optional protocol
    r'(?:' // Begin domain group
    r'(?:[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?\.)+[a-zA-Z]{2,}' // Domain with TLD
    r'|'
    r'localhost' // Or localhost
    r'|'
    r'\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}' // Or IP address
    r')' // End domain group
    r'(?::\d{1,5})?' // Optional port
    r'(?:\/[^\s]*)?' // Optional path
    r')$',
    caseSensitive: false,
  );

  /// Validates if a string is a valid URL
  ///
  /// Returns true if:
  /// - URL has valid format (with or without protocol)
  /// - Domain is valid
  /// - Not empty
  ///
  /// Returns false if:
  /// - Empty string
  /// - Invalid format
  /// - Malformed domain
  ///
  /// Examples:
  /// ```dart
  /// UrlValidator.isValid('https://example.com') // true
  /// UrlValidator.isValid('example.com')         // true
  /// UrlValidator.isValid('not a url')           // false
  /// UrlValidator.isValid('')                    // false
  /// ```
  static bool isValid(String url) {
    // Empty check
    if (url.trim().isEmpty) {
      return false;
    }

    // Basic regex validation
    if (!_urlRegex.hasMatch(url)) {
      return false;
    }

    // Additional validation for edge cases
    // Prevent URLs like "http://" or "https://"
    if (url.endsWith('://')) {
      return false;
    }

    // Prevent URLs with consecutive dots in domain
    if (url.contains('..')) {
      return false;
    }

    return true;
  }

  /// Normalizes a URL by adding https:// if protocol is missing
  ///
  /// Why normalize?
  /// Users often paste URLs without the protocol:
  /// - "example.com" instead of "https://example.com"
  /// - HTTP clients require a protocol to make requests
  /// - We default to https:// for security
  ///
  /// Rules:
  /// - If URL already has http:// or https:// → Keep it
  /// - If URL has no protocol → Add https://
  ///
  /// Examples:
  /// ```dart
  /// UrlValidator.normalize('example.com')
  /// // Returns: 'https://example.com'
  ///
  /// UrlValidator.normalize('http://example.com')
  /// // Returns: 'http://example.com' (unchanged)
  ///
  /// UrlValidator.normalize('https://example.com')
  /// // Returns: 'https://example.com' (unchanged)
  /// ```
  static String normalize(String url) {
    final trimmed = url.trim();

    // Check if URL already has protocol
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed;
    }

    // Add https:// by default
    return 'https://$trimmed';
  }

  /// Validates AND normalizes a URL in one call
  ///
  /// Convenience method that:
  /// 1. Normalizes the URL (adds https:// if needed)
  /// 2. Validates the normalized URL
  /// 3. Returns normalized URL if valid, null if invalid
  ///
  /// Returns:
  /// - Normalized URL string if valid
  /// - null if invalid
  ///
  /// Example:
  /// ```dart
  /// final url = UrlValidator.validateAndNormalize('example.com');
  /// // Returns: 'https://example.com'
  ///
  /// final invalid = UrlValidator.validateAndNormalize('not a url');
  /// // Returns: null
  /// ```
  static String? validateAndNormalize(String url) {
    // Normalize first (add https:// if needed)
    final normalized = normalize(url);

    // Then validate
    if (isValid(normalized)) {
      return normalized;
    }

    // If invalid even after normalization, return null
    return null;
  }
}

/// 🎓 Learning Summary: URL Validation
///
/// **What is a URL?**
/// URL = Uniform Resource Locator
/// A web address that tells you how to find something on the internet.
///
/// **Parts of a URL:**
/// ```
/// https://example.com:443/path?query=value#section
/// └─┬─┘  └────┬────┘ └┬┘ └─┬─┘ └──┬───────┘ └──┬──┘
///   │         │        │    │       │            │
/// Protocol  Domain   Port Path   Query      Fragment
/// ```
///
/// **Why Validation Matters:**
/// 1. **Security:** Prevent malicious URLs
/// 2. **User Experience:** Catch typos early
/// 3. **Data Quality:** Only save valid links
/// 4. **Error Prevention:** Don't try to fetch invalid URLs
///
/// **Regular Expressions (Regex):**
/// A pattern matching language for strings.
/// Think of it like a template that strings must match.
///
/// Our regex pattern:
/// - `^` = Start of string
/// - `(?:https?:\/\/)?` = Optional http:// or https://
/// - `[a-zA-Z0-9]` = Letters and numbers
/// - `\.` = Literal dot
/// - `+` = One or more
/// - `?` = Optional
/// - `$` = End of string
///
/// **Why normalize?**
/// Users paste URLs in different formats:
/// - "example.com"
/// - "www.example.com"
/// - "https://example.com"
///
/// We normalize to a consistent format (add https://) so:
/// - HTTP clients can make requests
/// - Database stores consistent data
/// - Duplicate detection works properly
///
/// **Static Methods:**
/// ```dart
/// static bool isValid(String url) { ... }
/// ```
///
/// Static = Belongs to the class, not instances
/// You call it directly: `UrlValidator.isValid(url)`
/// NOT: `UrlValidator().isValid(url)` ❌
///
/// Why static for utility functions?
/// - No state to maintain
/// - Pure functions (same input → same output)
/// - More efficient (no object creation)
/// - Clear usage pattern
///
/// **Next:**
/// Run tests to verify implementation passes (🟢 GREEN)
