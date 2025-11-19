library;

/// Add Link Flow Screen
///
/// Main controller for the entire Add Link flow.
/// Coordinates transitions between screens with smooth animations.
///
/// Flow:
/// 1. URL Input Screen (user enters URL)
/// 2. Loading Screen (fetching metadata, max 3s)
/// 3. Success Screen (link saved!)
/// 4. Add Details Modal (optional - tags/note/space)
///
/// Uses PageView for smooth transitions between steps 1-3.
/// Uses showModalBottomSheet for step 4.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/features/links/providers/add_link_provider.dart';
import 'package:mobile/features/links/screens/url_input_screen.dart';
import 'package:mobile/features/links/screens/link_success_screen.dart';
import 'package:mobile/features/links/screens/add_details_screen.dart';
import 'package:mobile/features/links/providers/link_provider.dart';
import 'package:mobile/features/links/providers/links_by_space_provider.dart';

class AddLinkFlowScreen extends ConsumerStatefulWidget {
  /// Optional: Pre-select a space when adding a link
  ///
  /// When adding a link from a Space Detail Screen, this will be the space ID.
  /// The link will be automatically assigned to this space.
  final String? initialSpaceId;

  /// Optional: Pre-filled URL from share extension
  ///
  /// When a URL is shared from another app (Safari, Chrome, etc.),
  /// this will contain the shared URL. The flow will skip the URL input
  /// screen and automatically save the link.
  final String? sharedUrl;

  const AddLinkFlowScreen({
    super.key,
    this.initialSpaceId,
    this.sharedUrl,
  });

  @override
  ConsumerState<AddLinkFlowScreen> createState() => _AddLinkFlowScreenState();
}

class _AddLinkFlowScreenState extends ConsumerState<AddLinkFlowScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isSharedUrl = false; // Track if this is a shared URL

  @override
  void initState() {
    super.initState();

    // Check if this is a shared URL from another app
    _isSharedUrl = widget.sharedUrl != null;

    // Pre-select space if initialSpaceId is provided
    // This ensures the link is created with the correct space_id
    // CRITICAL: Must happen BEFORE user enters URL and continues
    if (widget.initialSpaceId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref
            .read(addLinkProvider.notifier)
            .updateSpace(widget.initialSpaceId);
      });
    }

    // Auto-trigger save if URL is shared from another app
    if (widget.sharedUrl != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _handleSharedUrl();
      });
    }
  }

  /// Handle URL shared from another app (iOS Share Extension / Android ShareActivity)
  ///
  /// This bypasses the URL input screen and automatically:
  /// 1. Pre-fills the URL in the provider
  /// 2. Triggers metadata fetch and save
  /// 3. Shows loading → success screens
  void _handleSharedUrl() {
    debugPrint('🔵 [AddLinkFlow] Handling shared URL: ${widget.sharedUrl}');

    // Pre-fill URL in provider
    ref.read(addLinkProvider.notifier).updateUrl(widget.sharedUrl!);

    // Start the save process (skip URL input screen)
    ref.read(addLinkProvider.notifier).continueWithUrl();

    // Start on loading page (index 1) instead of URL input (index 0)
    if (_pageController.hasClients) {
      _pageController.jumpToPage(1);
      setState(() {
        _currentPage = 1;
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _animateToPage(int page) {
    setState(() {
      _currentPage = page;
    });
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _handleContinue() {
    ref.read(addLinkProvider.notifier).continueWithUrl();
  }

  void _handleDone() {
    // Get final space ID from add link state
    // This is the space the link was actually assigned to (may differ from initialSpaceId)
    final finalSpaceId = ref.read(addLinkProvider).spaceId;

    // Refresh home screen links
    ref.invalidate(linksWithTagsProvider);

    // Refresh space detail screen if link is assigned to a space
    // This handles ALL scenarios:
    // - Adding from home and assigning space in details
    // - Adding from space detail with pre-selected space
    // - Changing space in details screen
    if (finalSpaceId != null) {
      ref.invalidate(linksBySpaceProvider(finalSpaceId));
    }

    // Reset provider state
    ref.read(addLinkProvider.notifier).reset();

    // Close flow
    Navigator.pop(context);
  }

  void _handleAddDetails() {
    ref.read(addLinkProvider.notifier).startAddingDetails();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6, // Start at 60% of screen (half-screen)
        minChildSize: 0.6, // Can't go smaller than half-screen
        maxChildSize: 0.95, // Can expand to nearly full-screen
        snap: true, // Snap to half or full positions
        builder: (context, scrollController) => AddDetailsScreen(
          initialSpaceId: widget.initialSpaceId, // Pre-select space
          scrollController: scrollController, // Enable swipe-to-expand/collapse
          onDone: () {
            Navigator.pop(context); // Close modal
            _handleDone(); // Close entire flow
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Listen to flow state changes and update UI accordingly
    ref.listen<AddLinkState>(addLinkProvider, (previous, next) {
      // Navigate to loading when user hits Continue
      if (next.flowState == AddLinkFlowState.loading && _currentPage == 0) {
        _animateToPage(1);
      }

      // Navigate to success when link is saved
      if (next.flowState == AddLinkFlowState.success && _currentPage == 1) {
        _animateToPage(2);
      }

      // Show error if validation fails
      if (next.flowState == AddLinkFlowState.error && next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: Colors.red,
          ),
        );
      }
    });

    return PopScope(
      canPop: _currentPage == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _currentPage > 0) {
          _animateToPage(_currentPage - 1);
        }
      },
      child: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(), // Prevent manual swiping
        children: [
          // Page 1: URL Input
          UrlInputScreen(
            onContinue: _handleContinue,
          ),

          // Page 2: Loading
          _buildLoadingScreen(),

          // Page 3: Success
          LinkSuccessScreen(
            onDone: _handleDone,
            onAddDetails: _handleAddDetails,
            autoClose: false, // Always show buttons, let user control when to close
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingScreen() {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Loading indicator
              const SizedBox(
                width: 60,
                height: 60,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF075a52)),
                  strokeWidth: 4,
                ),
              ),

              const SizedBox(height: 24),

              // Loading text
              const Text(
                'Fetching metadata...',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 8),

              // Helper text
              Text(
                'This will only take a moment',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
