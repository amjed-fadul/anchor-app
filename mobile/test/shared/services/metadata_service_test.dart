/// Metadata Service Tests
///
/// Testing URL metadata extraction service.
/// Following TDD: Writing tests BEFORE implementation!
///
/// Test Strategy:
/// - Mock HTTP client to control responses
/// - Test success cases (valid metadata)
/// - Test error cases (network errors, timeouts, invalid HTML)
/// - Test fallback behavior (missing metadata fields)
///
/// Real-World Analogy:
/// Think of metadata fetching like a book scanner at a library:
/// - Success: Scans barcode, gets title, author, description
/// - Network Error: Scanner unplugged
/// - Invalid HTML: Barcode damaged, can't read
/// - Fallback: Use ISBN number as title if barcode fails

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/shared/services/metadata_service.dart';

/// Mock HTTP Client for testing
/// This lets us simulate different server responses without
/// making actual network requests
class MockHttpClient extends Mock implements http.Client {}

/// Mock HTTP Response for testing
class MockResponse extends Mock implements http.Response {}

void main() {
  group('MetadataService', () {
    late MetadataService service;
    late MockHttpClient mockClient;

    /// Setup before each test
    setUp(() {
      mockClient = MockHttpClient();
      service = MetadataService(client: mockClient);
    });

    /// Test #1: Successfully fetches complete metadata
    test('fetches complete metadata from valid URL', () async {
      // Arrange: Mock HTML response with all metadata
      const url = 'https://example.com';
      const htmlContent = '''
        <html>
          <head>
            <title>Example Page Title</title>
            <meta name="description" content="This is an example description" />
            <meta property="og:title" content="OG Title Override" />
            <meta property="og:description" content="OG Description Override" />
            <meta property="og:image" content="https://example.com/image.png" />
          </head>
          <body>
            <h1>Content</h1>
          </body>
        </html>
      ''';

      // Mock HTTP response
      when(() => mockClient.get(
            Uri.parse(url),
            headers: any(named: 'headers'),
          )).thenAnswer(
        (_) async => http.Response(htmlContent, 200),
      );

      // Act: Fetch metadata
      final result = await service.fetchMetadata(url);

      // Assert: Should return complete metadata
      expect(result.title, 'OG Title Override'); // Prefers og:title
      expect(result.description, 'OG Description Override');
      expect(result.thumbnailUrl, 'https://example.com/image.png');
      expect(result.domain, 'example.com');

      // Verify HTTP request was made
      verify(() => mockClient.get(
            Uri.parse(url),
            headers: any(named: 'headers'),
          )).called(1);
    });

    /// Test #2: Falls back to <title> tag when og:title is missing
    test('falls back to title tag when og:title is missing', () async {
      // Arrange
      const url = 'https://example.com';
      const htmlContent = '''
        <html>
          <head>
            <title>Regular Title Tag</title>
          </head>
        </html>
      ''';

      when(() => mockClient.get(
            Uri.parse(url),
            headers: any(named: 'headers'),
          )).thenAnswer(
        (_) async => http.Response(htmlContent, 200),
      );

      // Act
      final result = await service.fetchMetadata(url);

      // Assert: Should use regular title tag
      expect(result.title, 'Regular Title Tag');
    });

    /// Test #3: Uses domain as title when no title tags exist
    test('uses domain as title when no title found', () async {
      // Arrange
      const url = 'https://example.com';
      const htmlContent = '''
        <html>
          <head>
            <!-- No title tags -->
          </head>
        </html>
      ''';

      when(() => mockClient.get(
            Uri.parse(url),
            headers: any(named: 'headers'),
          )).thenAnswer(
        (_) async => http.Response(htmlContent, 200),
      );

      // Act
      final result = await service.fetchMetadata(url);

      // Assert: Should use domain as fallback
      expect(result.title, 'example.com');
      expect(result.domain, 'example.com');
    });

    /// Test #4: Handles network errors gracefully
    test('returns domain as title on network error', () async {
      // Arrange: Simulate network error
      const url = 'https://example.com';

      when(() => mockClient.get(
            Uri.parse(url),
            headers: any(named: 'headers'),
          )).thenThrow(
        Exception('Network error'),
      );

      // Act
      final result = await service.fetchMetadata(url);

      // Assert: Should return domain as fallback
      expect(result.title, 'example.com');
      expect(result.domain, 'example.com');
      expect(result.description, null);
      expect(result.thumbnailUrl, null);
    });

    /// Test #5: Handles HTTP error status codes
    test('returns domain as title on HTTP error (404, 500, etc)', () async {
      // Arrange: Simulate 404 Not Found
      const url = 'https://example.com/notfound';

      when(() => mockClient.get(
            Uri.parse(url),
            headers: any(named: 'headers'),
          )).thenAnswer(
        (_) async => http.Response('Not Found', 404),
      );

      // Act
      final result = await service.fetchMetadata(url);

      // Assert: Should return domain as fallback
      expect(result.title, 'example.com');
      expect(result.domain, 'example.com');
    });

    /// Test #6: Handles timeout gracefully
    test('returns domain as title on timeout', () async {
      // Arrange: Simulate timeout
      const url = 'https://example.com';

      when(() => mockClient.get(
            Uri.parse(url),
            headers: any(named: 'headers'),
          )).thenAnswer(
        (_) => Future.delayed(
          const Duration(seconds: 10),
          () => http.Response('', 200),
        ),
      );

      // Act: Should timeout after 5 seconds
      final result = await service.fetchMetadata(url);

      // Assert: Should return domain as fallback
      expect(result.title, 'example.com');
      expect(result.domain, 'example.com');
    });

    /// Test #7: Handles malformed HTML gracefully
    test('handles malformed HTML without crashing', () async {
      // Arrange: Invalid HTML
      const url = 'https://example.com';
      const htmlContent = '''
        <html>
          <head>
            <title>Test
            <!-- Unclosed tags, malformed HTML -->
          </head>
      ''';

      when(() => mockClient.get(
            Uri.parse(url),
            headers: any(named: 'headers'),
          )).thenAnswer(
        (_) async => http.Response(htmlContent, 200),
      );

      // Act: Should not throw exception
      final result = await service.fetchMetadata(url);

      // Assert: Should extract what it can
      expect(result.domain, 'example.com');
      // Title might be extracted despite malformed HTML
      expect(result.title, isNotEmpty);
    });

    /// Test #8: Extracts domain correctly from various URL formats
    test('extracts domain from URL with path and query', () async {
      // Arrange
      const url = 'https://example.com/path/to/page?query=value#fragment';
      const htmlContent = '<html><head><title>Test</title></head></html>';

      when(() => mockClient.get(
            Uri.parse(url),
            headers: any(named: 'headers'),
          )).thenAnswer(
        (_) async => http.Response(htmlContent, 200),
      );

      // Act
      final result = await service.fetchMetadata(url);

      // Assert: Should extract clean domain
      expect(result.domain, 'example.com');
    });

    /// Test #9: Handles www subdomain
    test('handles www subdomain in domain extraction', () async {
      // Arrange
      const url = 'https://www.example.com';
      const htmlContent = '<html><head><title>Test</title></head></html>';

      when(() => mockClient.get(
            Uri.parse(url),
            headers: any(named: 'headers'),
          )).thenAnswer(
        (_) async => http.Response(htmlContent, 200),
      );

      // Act
      final result = await service.fetchMetadata(url);

      // Assert: Could keep or remove www (your preference)
      expect(result.domain, anyOf('www.example.com', 'example.com'));
    });

    /// Test #10: Handles relative thumbnail URLs
    test('converts relative thumbnail URLs to absolute', () async {
      // Arrange
      const url = 'https://example.com';
      const htmlContent = '''
        <html>
          <head>
            <title>Test</title>
            <meta property="og:image" content="/images/thumbnail.png" />
          </head>
        </html>
      ''';

      when(() => mockClient.get(
            Uri.parse(url),
            headers: any(named: 'headers'),
          )).thenAnswer(
        (_) async => http.Response(htmlContent, 200),
      );

      // Act
      final result = await service.fetchMetadata(url);

      // Assert: Should convert to absolute URL
      expect(
        result.thumbnailUrl,
        'https://example.com/images/thumbnail.png',
      );
    });
  });
}

/// 🎓 Learning Summary: Testing Async Services with Mocks
///
/// **Why Mock HTTP Requests?**
/// In tests, we DON'T want to:
/// - Make real network requests (slow, unreliable)
/// - Depend on external websites (they might be down)
/// - Use up bandwidth
/// - Hit rate limits
///
/// Instead, we MOCK (simulate) the HTTP client:
/// ```dart
/// when(() => mockClient.get(...))
///   .thenAnswer((_) async => http.Response('fake data', 200));
/// ```
///
/// **How Mocking Works:**
/// 1. Create mock object: `MockHttpClient()`
/// 2. Define behavior: `when(() => mock.method()).thenAnswer(...)`
/// 3. Use mock in service: `MetadataService(client: mockClient)`
/// 4. Service thinks it's real HTTP client
/// 5. We control all responses
///
/// **Benefits of Mocking:**
/// - ✅ Tests run fast (no network delay)
/// - ✅ Tests are reliable (no external dependencies)
/// - ✅ Can simulate error cases (timeouts, 404s, etc.)
/// - ✅ Don't need internet connection to run tests
///
/// **Test Patterns:**
/// 1. **Arrange:** Set up mocks and data
/// 2. **Act:** Call the method being tested
/// 3. **Assert:** Verify the result
///
/// **verify() Pattern:**
/// ```dart
/// verify(() => mockClient.get(...)).called(1);
/// ```
///
/// This checks that the mock method was called exactly once.
/// Useful for ensuring your code makes the expected HTTP requests.
///
/// **Async Testing:**
/// ```dart
/// test('my async test', () async {
///   final result = await service.fetchMetadata(url);
///   expect(result.title, 'Expected Title');
/// });
/// ```
///
/// Note the `async` and `await` keywords!
/// Without these, the test would finish before the async operation completes.
///
/// **Next:**
/// Run these tests - they will FAIL (🔴 RED) because
/// MetadataService doesn't exist yet. Then we'll implement it
/// to make them pass (🟢 GREEN).
