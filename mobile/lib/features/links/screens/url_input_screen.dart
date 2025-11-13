library;

/// URL Input Screen
///
/// First screen in Add Link flow where user pastes their URL.
///
/// Design from Figma:
/// - Clean white background
/// - Back button top-left
/// - "New bookmark" title
/// - URL text field
/// - Helper text below field
/// - "Continue" button at bottom (teal)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/links/providers/add_link_provider.dart';

class UrlInputScreen extends ConsumerWidget {
  final VoidCallback onContinue;

  const UrlInputScreen({
    super.key,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final addLinkState = ref.watch(addLinkProvider);
    final addLinkNotifier = ref.read(addLinkProvider.notifier);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'New bookmark',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),

              // URL Text Field
              TextField(
                autofocus: true,
                keyboardType: TextInputType.url,
                textInputAction: TextInputAction.go,
                style: const TextStyle(fontSize: 16),
                decoration: InputDecoration(
                  hintText: 'Paste link here',
                  hintStyle: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 16,
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide:
                        const BorderSide(color: AnchorColors.anchorTeal, width: 2),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.red, width: 2),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.red, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  errorText: addLinkState.flowState == AddLinkFlowState.error
                      ? addLinkState.errorMessage
                      : null,
                ),
                onChanged: addLinkNotifier.updateUrl,
                onSubmitted: (_) {
                  if (addLinkState.url.isNotEmpty) {
                    onContinue();
                  }
                },
              ),

              const SizedBox(height: 12),

              // Helper Text
              Text(
                'Paste your link here and we will extract the metadata for you',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                  height: 1.4,
                ),
              ),

              const Spacer(),

              // Continue Button
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: addLinkState.url.isEmpty ? null : onContinue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AnchorColors.anchorTeal,
                    disabledBackgroundColor: Colors.grey[300],
                    foregroundColor: Colors.white,
                    disabledForegroundColor: Colors.grey[500],
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Continue',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
