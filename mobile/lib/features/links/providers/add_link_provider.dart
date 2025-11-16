library;

/// Add Link Provider
///
/// Manages the complete Add Link flow state including:
/// - URL input and validation
/// - Metadata fetching with timeout
/// - Saving link to database
/// - Optional details (tags, note, space)
/// - UI state transitions

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/features/links/models/link_model.dart';
import 'package:mobile/features/links/services/link_service.dart';
import 'package:mobile/shared/models/link_metadata.dart';
import 'package:mobile/shared/services/metadata_service.dart';
import 'package:mobile/shared/utils/url_validator.dart';
import 'package:mobile/features/auth/providers/auth_provider.dart';

/// Add Link Flow States
enum AddLinkFlowState {
  /// Step 1: User entering URL
  urlInput,

  /// Step 2: Fetching metadata and saving link
  loading,

  /// Step 3: Link saved successfully - show success screen
  success,

  /// Step 4: User adding optional details (tags, note, space)
  addingDetails,

  /// Error state
  error,
}

/// Add Link State Model
class AddLinkState {
  final String url;
  final LinkMetadata? metadata;
  final Link? savedLink;
  final AddLinkFlowState flowState;
  final String? errorMessage;
  final List<String> selectedTagIds;
  final String? note;
  final String? spaceId;
  final bool isSaving;

  const AddLinkState({
    this.url = '',
    this.metadata,
    this.savedLink,
    this.flowState = AddLinkFlowState.urlInput,
    this.errorMessage,
    this.selectedTagIds = const [],
    this.note,
    this.spaceId,
    this.isSaving = false,
  });

  AddLinkState copyWith({
    String? url,
    LinkMetadata? metadata,
    Link? savedLink,
    AddLinkFlowState? flowState,
    String? errorMessage,
    List<String>? selectedTagIds,
    String? note,
    String? spaceId,
    bool? isSaving,
  }) {
    return AddLinkState(
      url: url ?? this.url,
      metadata: metadata ?? this.metadata,
      savedLink: savedLink ?? this.savedLink,
      flowState: flowState ?? this.flowState,
      errorMessage: errorMessage,
      selectedTagIds: selectedTagIds ?? this.selectedTagIds,
      note: note ?? this.note,
      spaceId: spaceId ?? this.spaceId,
      isSaving: isSaving ?? this.isSaving,
    );
  }
}

/// Add Link Notifier
///
/// Handles all logic for the Add Link flow:
/// 1. Validate URL
/// 2. Fetch metadata (with 3s timeout)
/// 3. Save link immediately
/// 4. Optionally update with details
class AddLinkNotifier extends StateNotifier<AddLinkState> {
  final LinkService _linkService;
  final MetadataService _metadataService;
  final String _userId;

  AddLinkNotifier(this._linkService, this._metadataService, this._userId)
      : super(const AddLinkState());

  /// Update URL as user types
  void updateUrl(String url) {
    state = state.copyWith(url: url, errorMessage: null);
  }

  /// Validate URL and proceed to metadata fetch
  Future<void> continueWithUrl() async {
    // Validate URL
    final validationError = UrlValidator.validate(state.url);
    if (validationError != null) {
      state = state.copyWith(
        flowState: AddLinkFlowState.error,
        errorMessage: validationError,
      );
      return;
    }

    // Start loading state
    state = state.copyWith(
      flowState: AddLinkFlowState.loading,
      errorMessage: null,
    );

    try {
      // Normalize URL
      final normalizedUrl = UrlValidator.normalize(state.url);

      // Fetch metadata with 10s timeout
      LinkMetadata? metadata;
      try {
        debugPrint('🔍 [ADD_LINK] Starting metadata fetch for: ${state.url}');
        metadata = await _metadataService
            .fetchMetadata(state.url)
            .timeout(const Duration(seconds: 10));
        debugPrint('✅ [ADD_LINK] Metadata fetched successfully: ${metadata.title}');
      } catch (e) {
        // Timeout or error - continue without metadata
        // This is okay per user requirements
        debugPrint('❌ [ADD_LINK] Metadata fetch failed: $e');
        metadata = null;
      }

      // Save link to database IMMEDIATELY
      // (Even if metadata failed, we save the link)
      // If spaceId is set (from Space Detail Screen), link will be assigned to that space
      final savedLink = await _linkService.createLink(
        userId: _userId,
        url: state.url,
        normalizedUrl: normalizedUrl,
        title: metadata?.title,
        description: metadata?.description,
        thumbnailUrl: metadata?.thumbnailUrl,
        domain: UrlValidator.extractDomain(state.url),
        spaceId: state.spaceId, // ✅ Include space assignment
      );

      // Update state with saved link and metadata
      state = state.copyWith(
        metadata: metadata,
        savedLink: savedLink,
        flowState: AddLinkFlowState.success,
      );
    } catch (e) {
      state = state.copyWith(
        flowState: AddLinkFlowState.error,
        errorMessage: 'Failed to save link: ${e.toString()}',
      );
    }
  }

  /// User wants to add details (tags, note, space)
  void startAddingDetails() {
    state = state.copyWith(flowState: AddLinkFlowState.addingDetails);
  }

  /// Update selected tags
  void updateTags(List<String> tagIds) {
    state = state.copyWith(selectedTagIds: tagIds);
  }

  /// Update note
  void updateNote(String? note) {
    state = state.copyWith(note: note);
  }

  /// Update space selection
  void updateSpace(String? spaceId) {
    state = state.copyWith(spaceId: spaceId);
  }

  /// Save details and update the link in database
  Future<void> saveDetails() async {
    if (state.savedLink == null) return;

    state = state.copyWith(isSaving: true);

    try {
      // Update the link with new details using LinkService
      await _linkService.updateLink(
        linkId: state.savedLink!.id,
        note: state.note,
        spaceId: state.spaceId,
        tagIds: state.selectedTagIds.isEmpty ? null : state.selectedTagIds,
      );

      state = state.copyWith(isSaving: false);
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        errorMessage: 'Failed to update details: ${e.toString()}',
      );
    }
  }

  /// Reset to initial state (for new link)
  void reset() {
    state = const AddLinkState();
  }
}

/// Provider for Add Link flow
final addLinkProvider =
    StateNotifierProvider.autoDispose<AddLinkNotifier, AddLinkState>((ref) {
  final linkService = ref.watch(linkServiceProvider);
  final metadataService = ref.watch(metadataServiceProvider);
  final user = ref.watch(currentUserProvider);

  if (user == null) {
    throw Exception('User must be authenticated to add links');
  }

  return AddLinkNotifier(linkService, metadataService, user.id);
});
