/// Metadata Service
///
/// Fetches metadata (title, description, thumbnail) from web pages.
///
/// How It Works:
/// 1. Makes HTTP request to fetch HTML content
/// 2. Parses HTML to extract meta tags
/// 3. Returns LinkMetadata with extracted info
/// 4. Falls back to domain name if extraction fails
///
/// Real-World Analogy:
/// Think of this like a book scanner at a library:
/// - Scans the book cover (fetches HTML)
/// - Reads title, author, summary (parses meta tags)
/// - If barcode is damaged, uses shelf label (fallback to domain)
///
/// Usage:
/// ```dart
/// final service = MetadataService();
/// final metadata = await service.fetchMetadata('https://example.com');
/// print(metadata.title); // "Example Domain"
/// ```

import 'dart:async';
import 'package:html/parser.dart' as html_parser;
import 'package:html/dom.dart' as dom;
import 'package:http/http.dart' as http;
import '../models/link_metadata.dart';

class MetadataService {
  /// HTTP client for making requests
  /// Can be injected for testing (dependency injection)
  final http.Client client;

  /// Timeout duration for HTTP requests (5 seconds as per PRD)
  final Duration timeout;

  /// Constructor
  ///
  /// [client] - HTTP client (defaults to standard http.Client)
  /// [timeout] - Request timeout (defaults to 5 seconds)
  MetadataService({
    http.Client? client,
    this.timeout = const Duration(seconds: 5),
  }) : client = client ?? http.Client();

  /// Fetches metadata from a URL
  ///
  /// Steps:
  /// 1. Make HTTP GET request to URL
  /// 2. Parse HTML response
  /// 3. Extract meta tags (og:title, og:description, og:image)
  /// 4. Extract regular tags (<title>, <meta name="description">)
  /// 5. Return LinkMetadata with extracted data
  ///
  /// If any step fails, falls back to using domain as title.
  ///
  /// Example:
  /// ```dart
  /// final metadata = await service.fetchMetadata('https://example.com');
  /// // Returns: LinkMetadata(title: 'Example Domain', domain: 'example.com', ...)
  /// ```
  Future<LinkMetadata> fetchMetadata(String url) async {
    try {
      // Extract domain for fallback
      final domain = _extractDomain(url);

      // Make HTTP request with timeout
      final response = await client
          .get(
            Uri.parse(url),
            headers: {
              'User-Agent':
                  'Mozilla/5.0 (compatible; AnchorBot/1.0; +https://anchor.app)',
            },
          )
          .timeout(timeout);

      // Check if request was successful
      if (response.statusCode != 200) {
        // HTTP error (404, 500, etc.) - return fallback
        return _fallbackMetadata(domain);
      }

      // Parse HTML
      final document = html_parser.parse(response.body);

      // Extract metadata from parsed HTML
      final title = _extractTitle(document, domain);
      final description = _extractDescription(document);
      final thumbnailUrl = _extractThumbnail(document, url);

      return LinkMetadata(
        title: title,
        domain: domain,
        description: description,
        thumbnailUrl: thumbnailUrl,
      );
    } on TimeoutException catch (_) {
      // Request timed out - return fallback
      final domain = _extractDomain(url);
      return _fallbackMetadata(domain);
    } catch (e) {
      // Any other error (network, parsing, etc.) - return fallback
      final domain = _extractDomain(url);
      return _fallbackMetadata(domain);
    }
  }

  /// Extracts title from HTML document
  ///
  /// Priority order:
  /// 1. og:title meta tag (Open Graph title)
  /// 2. Regular <title> tag
  /// 3. Domain as fallback
  ///
  /// Why this order?
  /// - og:title is specifically for sharing/previews
  /// - Regular title might have extra text (e.g., "Page | Site Name")
  /// - Domain ensures we always have something
  String _extractTitle(dom.Document document, String fallbackDomain) {
    // Try og:title first
    final ogTitle = document.querySelector('meta[property="og:title"]');
    if (ogTitle != null) {
      final content = ogTitle.attributes['content'];
      if (content != null && content.trim().isNotEmpty) {
        return content.trim();
      }
    }

    // Try regular <title> tag
    final titleElement = document.querySelector('title');
    if (titleElement != null) {
      final text = titleElement.text.trim();
      if (text.isNotEmpty) {
        return text;
      }
    }

    // Fallback to domain
    return fallbackDomain;
  }

  /// Extracts description from HTML document
  ///
  /// Priority order:
  /// 1. og:description meta tag
  /// 2. Regular description meta tag
  /// 3. null (no description found)
  String? _extractDescription(dom.Document document) {
    // Try og:description first
    final ogDescription =
        document.querySelector('meta[property="og:description"]');
    if (ogDescription != null) {
      final content = ogDescription.attributes['content'];
      if (content != null && content.trim().isNotEmpty) {
        return content.trim();
      }
    }

    // Try regular description meta tag
    final description = document.querySelector('meta[name="description"]');
    if (description != null) {
      final content = description.attributes['content'];
      if (content != null && content.trim().isNotEmpty) {
        return content.trim();
      }
    }

    // No description found
    return null;
  }

  /// Extracts thumbnail URL from HTML document
  ///
  /// Priority order:
  /// 1. og:image meta tag
  /// 2. twitter:image meta tag
  /// 3. null (no image found)
  ///
  /// Also handles relative URLs by converting to absolute.
  String? _extractThumbnail(dom.Document document, String baseUrl) {
    String? imageUrl;

    // Try og:image first
    final ogImage = document.querySelector('meta[property="og:image"]');
    if (ogImage != null) {
      imageUrl = ogImage.attributes['content'];
    }

    // Try twitter:image if og:image not found
    if (imageUrl == null || imageUrl.trim().isEmpty) {
      final twitterImage = document.querySelector('meta[name="twitter:image"]');
      if (twitterImage != null) {
        imageUrl = twitterImage.attributes['content'];
      }
    }

    // Convert relative URL to absolute
    if (imageUrl != null && imageUrl.trim().isNotEmpty) {
      return _makeAbsoluteUrl(imageUrl.trim(), baseUrl);
    }

    return null;
  }

  /// Extracts domain from URL
  ///
  /// Examples:
  /// - https://example.com/path → example.com
  /// - http://www.example.com → www.example.com
  /// - https://example.com:8080 → example.com
  String _extractDomain(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.host;
    } catch (e) {
      // If URL parsing fails, return the URL as-is
      return url;
    }
  }

  /// Creates fallback metadata using just the domain
  ///
  /// Used when:
  /// - Network request fails
  /// - Request times out
  /// - HTML parsing fails
  /// - No metadata found in HTML
  LinkMetadata _fallbackMetadata(String domain) {
    return LinkMetadata(
      title: domain,
      domain: domain,
      description: null,
      thumbnailUrl: null,
    );
  }

  /// Converts relative URLs to absolute URLs
  ///
  /// Examples:
  /// - /images/thumb.png → https://example.com/images/thumb.png
  /// - //cdn.example.com/img.png → https://cdn.example.com/img.png
  /// - https://example.com/img.png → https://example.com/img.png (unchanged)
  String _makeAbsoluteUrl(String imageUrl, String baseUrl) {
    // Already absolute URL
    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      return imageUrl;
    }

    // Protocol-relative URL (//cdn.example.com/img.png)
    if (imageUrl.startsWith('//')) {
      final baseUri = Uri.parse(baseUrl);
      return '${baseUri.scheme}:$imageUrl';
    }

    // Relative URL (/images/thumb.png or images/thumb.png)
    final baseUri = Uri.parse(baseUrl);
    final absoluteUri = baseUri.resolve(imageUrl);
    return absoluteUri.toString();
  }

  /// Dispose method to clean up resources
  ///
  /// Call this when you're done with the service
  /// to close the HTTP client connection.
  void dispose() {
    client.close();
  }
}

/// 🎓 Learning Summary: Web Scraping & Metadata Extraction
///
/// **What is Web Scraping?**
/// Programmatically extracting data from websites by:
/// 1. Downloading HTML content
/// 2. Parsing the HTML structure
/// 3. Finding specific elements/tags
/// 4. Extracting their text or attributes
///
/// **Open Graph Protocol (og: tags):**
/// A standard created by Facebook for rich link previews.
///
/// Common tags:
/// - `<meta property="og:title" content="Page Title" />`
/// - `<meta property="og:description" content="Description" />`
/// - `<meta property="og:image" content="https://..." />`
///
/// Why websites use it:
/// - Better previews when shared on social media
/// - Controls how links appear in chat apps
/// - Standard format for metadata
///
/// **HTML Parsing:**
/// The `html` package parses HTML into a tree structure (DOM):
/// ```
/// <html>
///   <head>
///     <title>Example</title>
///     <meta property="og:title" content="OG Title" />
///   </head>
/// </html>
/// ```
///
/// Becomes a tree:
/// ```
/// html
///  └─ head
///      ├─ title ("Example")
///      └─ meta (property="og:title", content="OG Title")
/// ```
///
/// We can then query this tree:
/// ```dart
/// document.querySelector('title') // Finds <title> element
/// document.querySelector('meta[property="og:title"]') // Finds og:title meta tag
/// ```
///
/// **CSS Selectors:**
/// `querySelector()` uses CSS selector syntax:
/// - `'title'` = Find <title> tag
/// - `'meta[property="og:title"]'` = Find <meta> with property="og:title"
/// - `'meta[name="description"]'` = Find <meta> with name="description"
///
/// **Error Handling Strategy:**
/// We use try-catch with fallbacks:
/// 1. Try to fetch and parse normally
/// 2. If network error → Return domain as title
/// 3. If timeout → Return domain as title
/// 4. If parsing error → Return domain as title
///
/// Why?
/// - User still gets something useful (domain name)
/// - App doesn't crash
/// - Better UX than showing error message
///
/// **Timeout Pattern:**
/// ```dart
/// await client.get(...).timeout(Duration(seconds: 5));
/// ```
///
/// Why timeout?
/// - Some websites are very slow
/// - User shouldn't wait forever
/// - 5 seconds is good balance (per PRD spec)
///
/// **Dependency Injection:**
/// ```dart
/// MetadataService({http.Client? client})
///   : client = client ?? http.Client();
/// ```
///
/// This allows:
/// - Normal use: `MetadataService()` uses real HTTP client
/// - Testing: `MetadataService(client: mockClient)` uses fake client
/// - No need to modify code for testing!
///
/// **Relative vs Absolute URLs:**
/// HTML can have relative image paths:
/// - Relative: `/images/thumb.png`
/// - Absolute: `https://example.com/images/thumb.png`
///
/// We convert relative to absolute so images load correctly:
/// ```dart
/// baseUrl.resolve(relativeUrl) // Does the conversion
/// ```
///
/// **Next:**
/// Run tests to verify implementation passes (🟢 GREEN)
