library;

/// Profile Screen
///
/// Full-screen profile editing page where users can:
/// - View their email (read-only)
/// - Edit their display name
/// - Delete their account
///
/// Features:
/// - Label-on-top input fields (using AnchorTextField)
/// - Grey background for fields
/// - Icons inside fields (grey color)
/// - Save button at bottom
/// - Delete account button with confirmation

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../design_system/design_system.dart';
import '../../auth/providers/auth_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  bool _isLoading = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  /// Load current user data from Supabase
  void _loadUserData() {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      // Pre-populate name from user metadata or email
      final name = user.userMetadata?['display_name'] as String? ??
          user.email?.split('@')[0] ??
          '';
      _nameController.text = name;
    }
  }

  /// Save updated profile to Supabase
  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final newName = _nameController.text.trim();

      // Update user metadata in Supabase auth
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(
          data: {
            'display_name': newName,
          },
        ),
      );

      if (!mounted) return;

      // Invalidate provider to refresh user data
      ref.invalidate(currentUserProvider);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully!'),
          backgroundColor: AnchorColors.success,
          duration: Duration(seconds: 2),
        ),
      );

      // Navigate back
      context.pop();
    } catch (e) {
      if (!mounted) return;

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update profile: $e'),
          backgroundColor: AnchorColors.error,
          duration: const Duration(seconds: 3),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  /// Show delete account confirmation dialog
  Future<void> _showDeleteConfirmation() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure you want to delete your account?\n\n'
          'This action cannot be undone. All your links, spaces, '
          'and data will be permanently deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xffe70c31), // Red
            ),
            child: const Text('Delete Account'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await _deleteAccount();
    }
  }

  /// Delete user account
  Future<void> _deleteAccount() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Call delete account service
      await ref.read(authServiceProvider).deleteAccount();

      if (!mounted) return;

      // Navigate to login screen
      context.go('/login');
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete account: $e'),
          backgroundColor: AnchorColors.error,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    final email = user?.email ?? '';

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
          'Profile',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            // Content
            SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 8),

                    // Email field (read-only)
                    AnchorTextField(
                      label: 'Email',
                      controller: TextEditingController(text: email),
                      readOnly: true,
                      prefixIcon: Icon(
                        Icons.email_outlined,
                        color: Colors.grey[600],
                        size: 20,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // User Name field (editable)
                    AnchorTextField(
                      label: 'User Name',
                      controller: _nameController,
                      hintText: 'Enter your name',
                      prefixIcon: Icon(
                        Icons.person_outline,
                        color: Colors.grey[600],
                        size: 20,
                      ),
                      keyboardType: TextInputType.name,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _saveProfile(),
                    ),

                    const SizedBox(height: 300), // Spacer for delete button
                  ],
                ),
              ),
            ),

            // Fixed buttons at bottom
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    top: BorderSide(color: Colors.grey[200]!),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Save button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isSaving || _isLoading ? null : _saveProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AnchorColors.anchorTeal,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: _isSaving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Save',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Delete account button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: TextButton(
                        onPressed: _isSaving || _isLoading ? null : _showDeleteConfirmation,
                        style: TextButton.styleFrom(
                          backgroundColor: const Color(0xffffe7eb), // Light pink
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Color(0xffe70c31),
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Delete my account',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xffe70c31), // Red
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
