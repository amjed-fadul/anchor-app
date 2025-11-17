library;

/// Link Success Screen
///
/// Beautiful celebration screen after link is saved.
///
/// Design from Figma:
/// - Gradient background (green #A8FF78 → blue #78AFFF)
/// - Large "Anchored!" text
/// - Subtitle "Find it anytime"
/// - "+ Add Details" button (white with teal text)
/// - "Done" button (white)
///
/// Animations:
/// - Gradient fades in (500ms)
/// - Title scales up from 0.8 (400ms)
/// - Buttons slide up from bottom (300ms, delay 200ms)
///
/// Auto-Close Feature (for shared links):
/// - When autoClose is true, screen auto-dismisses after 3 seconds
/// - Shows progress bar at top counting down
/// - Shows "Tap anywhere to close" hint
/// - User can tap screen to close early

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LinkSuccessScreen extends StatefulWidget {
  final VoidCallback onDone;
  final VoidCallback onAddDetails;

  /// Enable 3-second auto-dismiss for shared links
  ///
  /// When true:
  /// - Shows progress bar countdown at top
  /// - Auto-dismisses after 3 seconds
  /// - Screen is tappable to dismiss early
  /// - Shows "Tap anywhere to close" hint
  ///
  /// When false (default):
  /// - Shows normal "Add Details" and "Done" buttons
  /// - User manually dismisses
  final bool autoClose;

  const LinkSuccessScreen({
    super.key,
    required this.onDone,
    required this.onAddDetails,
    this.autoClose = false,
  });

  @override
  State<LinkSuccessScreen> createState() => _LinkSuccessScreenState();
}

class _LinkSuccessScreenState extends State<LinkSuccessScreen>
    with TickerProviderStateMixin {
  late AnimationController _gradientController;
  late AnimationController _titleController;
  late AnimationController _buttonsController;
  AnimationController? _progressController; // Optional for autoClose

  late Animation<double> _gradientOpacity;
  late Animation<double> _titleScale;
  late Animation<Offset> _buttonsSlide;

  @override
  void initState() {
    super.initState();

    // Haptic feedback on success
    HapticFeedback.mediumImpact();

    // Gradient fade animation
    _gradientController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _gradientOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _gradientController, curve: Curves.easeIn),
    );

    // Title scale animation
    _titleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _titleScale = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _titleController, curve: Curves.easeOut),
    );

    // Buttons slide animation
    _buttonsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _buttonsSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _buttonsController, curve: Curves.easeOut),
    );

    // Progress bar animation (only if autoClose is enabled)
    if (widget.autoClose) {
      _progressController = AnimationController(
        vsync: this,
        duration: const Duration(seconds: 3),
      );

      _progressController!.forward();

      // Auto-dismiss after 3 seconds
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          debugPrint('🔵 [LinkSuccess] Auto-closing after 3 seconds');
          widget.onDone();
        }
      });
    }

    // Start animations in sequence
    _gradientController.forward();
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) _titleController.forward();
    });
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _buttonsController.forward();
    });
  }

  @override
  void dispose() {
    _gradientController.dispose();
    _titleController.dispose();
    _buttonsController.dispose();
    _progressController?.dispose();
    super.dispose();
  }

  /// Handle tap anywhere on screen to dismiss early (only when autoClose is true)
  void _handleTapToDismiss() {
    if (widget.autoClose) {
      debugPrint('🔵 [LinkSuccess] User tapped to dismiss early');
      widget.onDone();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: GestureDetector(
          // Allow tap to dismiss early when autoClose is enabled
          onTap: widget.autoClose ? _handleTapToDismiss : null,
          behavior: HitTestBehavior.opaque,
          child: Column(
            children: [
              // Progress bar at top (only shown when autoClose is enabled)
              if (widget.autoClose && _progressController != null)
                AnimatedBuilder(
                  animation: _progressController!,
                  builder: (context, child) {
                    return LinearProgressIndicator(
                      value: _progressController!.value,
                      backgroundColor: Colors.white.withValues(alpha: 0.3),
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                      minHeight: 4,
                    );
                  },
                ),

              // Main content with gradient background
              Expanded(
                child: AnimatedBuilder(
                  animation: Listenable.merge([
                    _gradientOpacity,
                    _titleScale,
                    _buttonsSlide,
                  ]),
                  builder: (context, child) {
                    return Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            const Color(0xFFA8FF78).withValues(alpha: _gradientOpacity.value),
                            const Color(0xFF78AFFF).withValues(alpha: _gradientOpacity.value),
                          ],
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: [
                            const Spacer(flex: 2),

                            // "Anchored!" title with scale animation
                            Transform.scale(
                              scale: _titleScale.value,
                              child: const Column(
                                children: [
                                  Text(
                                    'Anchored!',
                                    style: TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Find it anytime',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.normal,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const Spacer(flex: 1),

                            // Buttons with slide animation (or tap hint for autoClose)
                            SlideTransition(
                              position: _buttonsSlide,
                              child: FadeTransition(
                                opacity: _buttonsController,
                                child: Column(
                                  children: [
                                    // Show buttons OR tap hint depending on autoClose
                                    if (!widget.autoClose) ...[
                                      // "+ Add Details" button
                                      SizedBox(
                                        width: double.infinity,
                                        height: 56,
                                        child: OutlinedButton(
                                          onPressed: widget.onAddDetails,
                                          style: OutlinedButton.styleFrom(
                                            backgroundColor: Colors.white,
                                            foregroundColor: const Color(0xFF075a52),
                                            side: const BorderSide(color: Colors.white, width: 2),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            elevation: 0,
                                          ),
                                          child: const Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons.add, size: 20),
                                              SizedBox(width: 8),
                                              Text(
                                                'Add Details',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),

                                      const SizedBox(height: 40),

                                      // "Done" button
                                      SizedBox(
                                        width: double.infinity,
                                        height: 56,
                                        child: ElevatedButton(
                                          onPressed: widget.onDone,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.white,
                                            foregroundColor: const Color(0xFF075a52),
                                            elevation: 0,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                          ),
                                          child: const Text(
                                            'Done',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ),

                                      const SizedBox(height: 24),
                                    ] else ...[
                                      // Tap anywhere hint (when autoClose is enabled)
                                      const Text(
                                        'Tap anywhere to close',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.black54,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 24),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
