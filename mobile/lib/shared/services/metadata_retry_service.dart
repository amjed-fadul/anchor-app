library;

/// MetadataRetryService
///
/// Service for retrying failed metadata fetches in the background.
///
/// Why Background Retry?
/// Metadata fetch can fail for temporary reasons (poor network, slow website, etc.).
/// Instead of giving up forever after one failure, we retry when network conditions
/// might be better (e.g., when user opens the app again).
///
/// Real-World Analogy:
/// Think of this like a mail delivery service:
/// - First attempt: Mail truck tries to deliver package, nobody home
/// - Background retry: Truck comes back later when you're more likely to be home
/// - Multiple attempts: Tries a few times before giving up
///
/// How It Works:
/// 1. Triggered when app comes to foreground (user opens app)
/// 2. Fetches links with incomplete metadata (metadata_complete = false)
/// 3. Retries metadata fetch for each link (max 10 at a time)
/// 4. Updates link in database with new metadata
/// 5. Stops retrying after 3 total attempts

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/links/services/link_service.dart';
import '../../features/links/models/link_model.dart';
import '../services/metadata_service.dart';

/// MetadataRetryService - Handles background metadata retry logic
class MetadataRetryService {
  final LinkService _linkService;
  final MetadataService _metadataService;

  /// Last time we ran a retry batch (to prevent spamming)
  DateTime? _lastRetryTime;

  /// Minimum duration between global retry batches (1 second)
  /// This controls how often we check for incomplete links when app comes to foreground.
  /// Short interval = fast recovery when user reopens app.
  static const Duration _minGlobalRetryInterval = Duration(seconds: 1);

  /// Minimum duration between retry attempts for the SAME link (1 minute)
  /// This prevents hammering individual slow/broken links.
  /// Longer interval per link = protection against repeatedly hitting failing URLs.
  static const Duration _minPerLinkRetryInterval = Duration(minutes: 1);

  /// Maximum number of links to retry per batch (to avoid hammering network)
  static const int _maxBatchSize = 10;

  MetadataRetryService(this._linkService, this._metadataService);

  /// retryIncompleteLinks - Retry metadata fetch for links with incomplete metadata
  ///
  /// This method:
  /// 1. Checks if enough time has passed since last retry (debouncing)
  /// 2. Fetches links with incomplete metadata (max 10)
  /// 3. For each link, retries metadata fetch
  /// 4. Updates link in database with new metadata
  /// 5. Increments fetch attempt counter
  ///
  /// Parameters:
  /// - userId: ID of the user whose links to retry
  ///
  /// Returns:
  /// Number of links successfully updated
  ///
  /// Called by:
  /// AppLifecycleService when app comes to foreground
  ///
  /// Example:
  /// ```dart
  /// final updatedCount = await metadataRetryService.retryIncompleteLinks(userId);
  /// debugPrint('Updated $updatedCount links');
  /// ```
  Future<int> retryIncompleteLinks(String userId) async {
    try {
      // Step 1: Debounce - Check if enough time has passed since last retry
      if (_lastRetryTime != null) {
        final timeSinceLastRetry = DateTime.now().difference(_lastRetryTime!);
        if (timeSinceLastRetry < _minGlobalRetryInterval) {
          debugPrint(
            '⏭️ [MetadataRetry] Skipping global retry - only ${timeSinceLastRetry.inSeconds} seconds since last retry (minimum: ${_minGlobalRetryInterval.inSeconds} seconds)',
          );
          return 0;
        }
      }

      debugPrint('🔵 [MetadataRetry] Starting background metadata retry for user $userId');
      _lastRetryTime = DateTime.now();

      // Step 2: Fetch links with incomplete metadata
      final incompleteLinks = await _linkService.getLinksWithIncompleteMetadata(
        userId,
        limit: _maxBatchSize,
      );

      if (incompleteLinks.isEmpty) {
        debugPrint('🟢 [MetadataRetry] No links need metadata retry');
        return 0;
      }

      debugPrint('🔵 [MetadataRetry] Retrying metadata for ${incompleteLinks.length} links');

      // Step 3: Retry metadata fetch for each link
      int successCount = 0;
      for (final link in incompleteLinks) {
        try {
          await _retryLinkMetadata(link);
          successCount++;
        } catch (e) {
          // Continue with next link even if this one fails
          debugPrint('🔴 [MetadataRetry] Failed to retry link ${link.id}: $e');
        }
      }

      debugPrint('🟢 [MetadataRetry] Successfully updated $successCount/${incompleteLinks.length} links');
      return successCount;
    } catch (e) {
      debugPrint('🔴 [MetadataRetry] Error during metadata retry: $e');
      return 0;
    }
  }

  /// _retryLinkMetadata - Retry metadata fetch for a single link (private method)
  ///
  /// This method:
  /// 1. Checks if link should be retried (last attempt > 1 minute ago)
  /// 2. Fetches metadata using MetadataService
  /// 3. Updates link in database with new metadata
  /// 4. Increments attempt counter
  ///
  /// Parameters:
  /// - link: Link to retry
  ///
  /// Throws:
  /// Exception if metadata fetch or database update fails
  Future<void> _retryLinkMetadata(Link link) async {
    // Check if we should retry this link (debounce per-link)
    if (link.lastMetadataAttemptAt != null) {
      final timeSinceLastAttempt = DateTime.now().difference(link.lastMetadataAttemptAt!);
      if (timeSinceLastAttempt < _minPerLinkRetryInterval) {
        debugPrint(
          '⏭️ [MetadataRetry] Skipping link ${link.id} - only ${timeSinceLastAttempt.inMinutes} minutes since last attempt (minimum: ${_minPerLinkRetryInterval.inMinutes} minutes)',
        );
        return;
      }
    }

    debugPrint('🔵 [MetadataRetry] Retrying metadata for link: ${link.url} (attempt #${link.metadataFetchAttempts + 1})');

    try {
      // Fetch metadata with 10s timeout
      final (metadata, finalUrl) = await _metadataService
          .fetchMetadataWithFinalUrl(link.url)
          .timeout(const Duration(seconds: 10));

      // Check if metadata fetch succeeded (has meaningful data)
      // If title equals domain, it means we got fallback metadata only
      final hasMetadata = metadata.title != metadata.domain;

      debugPrint(
        hasMetadata
            ? '🟢 [MetadataRetry] Successfully fetched metadata for ${link.url}'
            : '⚠️ [MetadataRetry] Metadata fetch returned fallback data for ${link.url}',
      );

      // Update link with new metadata
      // Also update URL if it redirected to a different destination
      await _linkService.updateLinkMetadata(
        linkId: link.id,
        url: finalUrl != link.url ? finalUrl : null,
        title: metadata.title,
        description: metadata.description,
        thumbnailUrl: metadata.thumbnailUrl,
        domain: metadata.domain,
        metadataComplete: hasMetadata, // Only mark complete if we got real metadata
        metadataFetchAttempts: link.metadataFetchAttempts + 1,
      );

      debugPrint('🟢 [MetadataRetry] Updated link ${link.id} in database');
    } catch (e) {
      // Metadata fetch failed - increment attempt counter without updating metadata
      debugPrint('🔴 [MetadataRetry] Metadata fetch failed for ${link.url}: $e');

      // Still update the link to increment attempt counter and timestamp
      await _linkService.updateLinkMetadata(
        linkId: link.id,
        title: link.title, // Keep existing title
        description: link.description, // Keep existing description
        thumbnailUrl: link.thumbnailUrl, // Keep existing thumbnail
        domain: link.domain, // Keep existing domain
        metadataComplete: false, // Still incomplete
        metadataFetchAttempts: link.metadataFetchAttempts + 1,
      );

      debugPrint('🔴 [MetadataRetry] Incremented attempt counter for link ${link.id}');
    }
  }
}

/// Provider for MetadataRetryService instance
///
/// This is a singleton - only one MetadataRetryService exists for the whole app.
final metadataRetryServiceProvider = Provider<MetadataRetryService>((ref) {
  final linkService = ref.watch(linkServiceProvider);
  final metadataService = ref.watch(metadataServiceProvider);
  return MetadataRetryService(linkService, metadataService);
});

/// 🎓 Learning Summary: Background Services
///
/// **What is a Background Service?**
/// A service that runs tasks when the user isn't directly interacting with that feature.
/// It improves user experience by fixing problems "behind the scenes" without user action.
///
/// **Real-World Analogy:**
/// Think of this like a phone's auto-sync feature:
/// - You take photos (like saving links)
/// - Photos auto-upload to cloud when WiFi is available (like metadata retry)
/// - You don't have to manually trigger upload (happens automatically in background)
/// - Retries if upload fails initially (resilience)
///
/// **Why Background Services?**
/// 1. **Improved Success Rate**: Retry during better network conditions
/// 2. **Better UX**: User doesn't see failures, problems are fixed automatically
/// 3. **Resilience**: Handles temporary failures gracefully
/// 4. **Efficiency**: Batch processing saves resources
///
/// **Key Patterns:**
/// - Debouncing: Prevent spamming by enforcing minimum time between attempts
/// - Batch Processing: Limit concurrent operations to avoid overwhelming system
/// - Graceful Degradation: Continue even if some operations fail
/// - Incremental Progress: Track attempts to avoid infinite retry loops
///
/// **Lifecycle Integration:**
/// This service is triggered by AppLifecycleService when app comes to foreground.
/// This ensures retries happen when user is likely online and network is available.
