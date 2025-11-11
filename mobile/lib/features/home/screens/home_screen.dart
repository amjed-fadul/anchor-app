import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../design_system/design_system.dart';
import '../../auth/providers/auth_provider.dart';

/// Home screen (main app screen after login)
///
/// This is where users will see their saved links organized by spaces.
/// For now, it's a placeholder that shows the user is logged in.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Anchor'),
        actions: [
          // Logout button
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final authService = ref.read(authServiceProvider);
              await authService.signOut();
            },
            tooltip: 'Sign Out',
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: AnchorSpacing.screenPadding,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.check_circle_outline,
                size: 80,
                color: AnchorColors.success,
              ),
              AnchorSpacing.verticalSpaceMD,
              Text(
                'Welcome to Anchor!',
                style: AnchorTypography.displaySmall,
                textAlign: TextAlign.center,
              ),
              AnchorSpacing.verticalSpaceSM,
              if (user != null)
                Text(
                  user.email ?? 'User',
                  style: AnchorTypography.bodyLarge.copyWith(
                    color: AnchorColors.gray600,
                  ),
                  textAlign: TextAlign.center,
                ),
              AnchorSpacing.verticalSpaceLG,
              Text(
                'You\'re logged in! 🎉',
                style: AnchorTypography.bodyMedium.copyWith(
                  color: AnchorColors.gray500,
                ),
                textAlign: TextAlign.center,
              ),
              AnchorSpacing.verticalSpaceSM,
              Text(
                'This is where your saved links will appear.',
                style: AnchorTypography.bodyMedium.copyWith(
                  color: AnchorColors.gray500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
