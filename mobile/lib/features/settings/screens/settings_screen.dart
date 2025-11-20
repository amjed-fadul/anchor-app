library;

/// Settings Screen
///
/// Displays user settings, account options, support links, and app information.
///
/// Features:
/// - User profile editing
/// - Dark mode toggle (UI only - coming soon)
/// - Tutorial access
/// - Community links (Reddit)
/// - Support links (Report Issue, Feature Requests)
/// - Legal pages (Terms, Privacy Policy)
/// - Sign out functionality
/// - App version display

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../../design_system/design_system.dart';
import '../../auth/providers/auth_provider.dart';
import '../widgets/edit_profile_dialog.dart';
import 'webview_screen.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  String _appVersion = '';
  bool _isDarkModeEnabled = false; // For future dark mode implementation

  @override
  void initState() {
    super.initState();
    _loadAppVersion();
  }

  /// Load app version from package info
  Future<void> _loadAppVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _appVersion = 'v${packageInfo.version}';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Settings',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 8),

              // ACCOUNT SECTION
              _buildSectionHeader('Account'),

              // User Profile
              _buildListTile(
                iconPath: 'assets/images/user.svg',
                title: 'User Profile',
                onTap: _showEditProfileDialog,
              ),

              // Dark mode
              _buildToggleTile(
                iconPath: null, // Using Material icon for moon
                materialIcon: Icons.nightlight_round,
                title: 'Dark mode',
                value: _isDarkModeEnabled,
                onChanged: (value) {
                  // Show "Coming soon" message
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Dark mode coming soon!'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),

              const SizedBox(height: 24),

              // SUPPORT SECTION
              _buildSectionHeader('Support'),

              // Open Tutorial
              _buildListTile(
                iconPath: null, // Using Material icon for play
                materialIcon: Icons.play_circle_outline,
                title: 'Open Tutorial',
                onTap: _showComingSoonMessage,
              ),

              // Reddit Community
              _buildListTile(
                iconPath: null, // Using Material icon for community
                materialIcon: Icons.groups,
                title: 'Reddit Community',
                showExternalLinkIcon: true,
                onTap: () => _launchUrl('https://reddit.com/r/anchorapp'),
              ),

              // Report an Issue
              _buildListTile(
                iconPath: 'assets/images/report an issue.svg',
                title: 'Report an Issue',
                showExternalLinkIcon: true,
                onTap: () => _launchUrl('https://github.com/amjed-fadul/anchor-app/issues'),
              ),

              // Feature Requests
              _buildListTile(
                iconPath: 'assets/images/feature request.svg',
                title: 'Feature Requests',
                showExternalLinkIcon: true,
                onTap: () => _launchUrl('https://github.com/amjed-fadul/anchor-app/discussions'),
              ),

              const SizedBox(height: 24),

              // LEGAL SECTION
              _buildSectionHeader('Legal'),

              // Terms and Conditions
              _buildListTile(
                iconPath: 'assets/images/terms and conditions.svg',
                title: 'Terms and Conditions',
                showExternalLinkIcon: true,
                onTap: () => _openWebView(
                  'Terms and Conditions',
                  'https://anchor-app.com/terms', // TODO: Update with actual URL
                ),
              ),

              // Privacy Policy
              _buildListTile(
                iconPath: 'assets/images/privacy policy.svg',
                title: 'Privacy Policy',
                showExternalLinkIcon: true,
                onTap: () => _openWebView(
                  'Privacy Policy',
                  'https://anchor-app.com/privacy', // TODO: Update with actual URL
                ),
              ),

              const SizedBox(height: 24),

              // SIGN OUT
              _buildListTile(
                iconPath: 'assets/images/logout-circle-01.svg',
                title: 'Sign out',
                titleColor: Colors.red,
                iconColor: Colors.red,
                onTap: () => _handleLogout(context, ref),
              ),

              const SizedBox(height: 32),

              // App version footer
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  _appVersion.isNotEmpty ? _appVersion : 'v1.0.0',
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 12,
                  ),
                ),
              ),

              const SizedBox(height: 40), // Bottom padding for home indicator
            ],
          ),
        ),
      ),
    );
  }

  /// Build section header
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title.toUpperCase(),
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  /// Build list tile for settings item
  Widget _buildListTile({
    String? iconPath,
    IconData? materialIcon,
    required String title,
    String? subtitle,
    Color? iconColor,
    Color? titleColor,
    bool showExternalLinkIcon = false,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: iconPath != null
            ? SvgPicture.asset(
                iconPath,
                width: 24,
                height: 24,
                colorFilter: ColorFilter.mode(
                  iconColor ?? Colors.black,
                  BlendMode.srcIn,
                ),
              )
            : Icon(
                materialIcon ?? Icons.settings,
                color: iconColor ?? Colors.black,
                size: 24,
              ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: titleColor ?? Colors.black,
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              )
            : null,
        trailing: showExternalLinkIcon
            ? Icon(
                Icons.open_in_new,
                color: Colors.grey[400],
                size: 20,
              )
            : null,
        onTap: onTap,
      ),
    );
  }

  /// Build toggle tile for dark mode
  Widget _buildToggleTile({
    String? iconPath,
    IconData? materialIcon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: iconPath != null
            ? SvgPicture.asset(
                iconPath,
                width: 24,
                height: 24,
                colorFilter: const ColorFilter.mode(
                  Colors.black,
                  BlendMode.srcIn,
                ),
              )
            : Icon(
                materialIcon ?? Icons.settings,
                color: Colors.black,
                size: 24,
              ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
        trailing: Switch(
          value: value,
          onChanged: onChanged,
          activeTrackColor: AnchorColors.anchorTeal,
          activeColor: AnchorColors.anchorTeal.withValues(alpha: 0.8),
        ),
      ),
    );
  }

  /// Show edit profile dialog
  void _showEditProfileDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const EditProfileDialog(),
    ).then((result) {
      // If profile was updated, show success message
      if (result == true && mounted) {
        // Refresh user data if needed
        ref.invalidate(currentUserProvider);
      }
    });
  }

  /// Show "Coming soon" message
  void _showComingSoonMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Coming soon!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  /// Launch external URL
  Future<void> _launchUrl(String urlString) async {
    try {
      final url = Uri.parse(urlString);
      if (!await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      )) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Could not open $urlString'),
              backgroundColor: AnchorColors.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to open link: $e'),
            backgroundColor: AnchorColors.error,
          ),
        );
      }
    }
  }

  /// Open WebView for legal pages
  void _openWebView(String title, String url) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => WebViewScreen(
          url: url,
          title: title,
        ),
      ),
    );
  }

  /// Handle logout with confirmation dialog
  Future<void> _handleLogout(BuildContext context, WidgetRef ref) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );

    // If user confirmed, perform logout
    if (confirmed == true && context.mounted) {
      try {
        // Call logout from auth provider
        await ref.read(authServiceProvider).signOut();

        // Navigate to login screen
        if (context.mounted) {
          context.go('/login');
        }
      } catch (e) {
        // Show error message
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to sign out: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}
