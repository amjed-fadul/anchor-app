import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'design_system/design_system.dart';
import 'core/config/supabase_config.dart';
import 'core/router/app_router.dart';
import 'core/services/deep_link_service.dart';
import 'core/services/app_lifecycle_service.dart';

/// App entry point
///
/// This function:
/// 1. Initializes Flutter framework
/// 2. Initializes Supabase (loads credentials, sets up auth)
/// 3. Processes deep links for password reset / OAuth
/// 4. Launches the app wrapped in ProviderScope for state management
Future<void> main() async {
  // Ensure Flutter is initialized before running async operations
  // Think of this like turning on the power before using appliances
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase (loads .env, connects to backend)
  // This MUST happen before the app runs, otherwise auth won't work
  // NOTE: detectSessionInUri is set to false, so Supabase won't
  // automatically process deep links (we handle them manually below)
  await initializeSupabase();

  // NOTE: Deep link processing is now managed by Riverpod
  // The deepLinkServiceProvider automatically initializes when first accessed
  // and persists for the app lifetime. This ensures:
  // - Deep links are processed before router initializes (for password reset)
  // - Stream listeners persist across app lifecycle
  // - HomeScreen can reactively respond to incoming shares

  // Run the app
  // ProviderScope wraps the whole app to enable Riverpod state management
  runApp(
    const ProviderScope(
      child: AnchorApp(),
    ),
  );
}

class AnchorApp extends ConsumerWidget {
  const AnchorApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Initialize deep link service early to process password reset links
    // This must happen before router initializes
    ref.read(deepLinkServiceProvider);

    // Initialize app lifecycle service to handle background metadata retries
    // This listens to app foreground/background events and triggers metadata retry
    ref.read(appLifecycleServiceProvider).initialize();

    // Get the router from our provider
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Anchor',
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AnchorColors.anchorTeal,
          primary: AnchorColors.anchorTeal,
          secondary: AnchorColors.anchorSlate,
        ),
        textTheme: AnchorTypography.textTheme,
        chipTheme: AnchorButtonStyles.chipTheme,
        scaffoldBackgroundColor: AnchorColors.white,
        appBarTheme: AppBarTheme(
          backgroundColor: AnchorColors.white,
          foregroundColor: AnchorColors.anchorSlate,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: AnchorTypography.headlineSmall,
        ),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Anchor Design System'),
      ),
      body: SingleChildScrollView(
        padding: AnchorSpacing.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Section
            Text(
              'Welcome to Anchor',
              style: AnchorTypography.displaySmall,
            ),
            AnchorSpacing.verticalSpaceSM,
            Text(
              'Your visual bookmark manager',
              style: AnchorTypography.bodyLarge.copyWith(
                color: AnchorColors.gray600,
              ),
            ),
            AnchorSpacing.verticalSpaceXL,

            // Colors Section
            Text('Brand Colors', style: AnchorTypography.headlineSmall),
            AnchorSpacing.verticalSpaceMD,
            Row(
              children: [
                _ColorBox(
                  color: AnchorColors.anchorTeal,
                  label: 'Anchor Teal',
                ),
                AnchorSpacing.horizontalSpaceMD,
                _ColorBox(
                  color: AnchorColors.anchorSlate,
                  label: 'Anchor Slate',
                ),
              ],
            ),
            AnchorSpacing.verticalSpaceXL,

            // Space Colors Section
            Text('Space Colors', style: AnchorTypography.headlineSmall),
            AnchorSpacing.verticalSpaceMD,
            Wrap(
              spacing: AnchorSpacing.sm,
              runSpacing: AnchorSpacing.sm,
              children: AnchorColors.allSpaceColors
                  .map((color) => Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: AnchorSpacing.radiusSM,
                        ),
                      ))
                  .toList(),
            ),
            AnchorSpacing.verticalSpaceXL,

            // Buttons Section
            Text('Buttons', style: AnchorTypography.headlineSmall),
            AnchorSpacing.verticalSpaceMD,
            AnchorButton(
              label: 'Primary Button',
              onPressed: () {},
              fullWidth: true,
            ),
            AnchorSpacing.verticalSpaceSM,
            AnchorButton(
              label: 'Secondary Button',
              onPressed: () {},
              type: AnchorButtonType.secondary,
              fullWidth: true,
            ),
            AnchorSpacing.verticalSpaceSM,
            AnchorButton(
              label: 'Tertiary Button',
              onPressed: () {},
              type: AnchorButtonType.tertiary,
              fullWidth: true,
            ),
            AnchorSpacing.verticalSpaceSM,
            Row(
              children: [
                Expanded(
                  child: AnchorButton(
                    label: 'With Icon',
                    onPressed: () {},
                    icon: Icons.bookmark,
                  ),
                ),
                AnchorSpacing.horizontalSpaceSM,
                Expanded(
                  child: AnchorButton(
                    label: 'Loading',
                    onPressed: () {},
                    isLoading: true,
                  ),
                ),
              ],
            ),
            AnchorSpacing.verticalSpaceMD,
            Row(
              children: [
                AnchorIconButton(
                  icon: Icons.favorite_border,
                  onPressed: () {},
                  tooltip: 'Like',
                ),
                AnchorSpacing.horizontalSpaceSM,
                AnchorIconButton(
                  icon: Icons.share,
                  onPressed: () {},
                  filled: true,
                  tooltip: 'Share',
                ),
                AnchorSpacing.horizontalSpaceSM,
                AnchorIconButton(
                  icon: Icons.add,
                  onPressed: () {},
                  primary: true,
                  tooltip: 'Add',
                ),
              ],
            ),
            AnchorSpacing.verticalSpaceXL,

            // Typography Section
            Text('Typography', style: AnchorTypography.headlineSmall),
            AnchorSpacing.verticalSpaceMD,
            Text('Display Large', style: AnchorTypography.displayLarge),
            Text('Headline Medium', style: AnchorTypography.headlineMedium),
            Text('Title Large', style: AnchorTypography.titleLarge),
            Text('Body Large', style: AnchorTypography.bodyLarge),
            Text('Label Medium', style: AnchorTypography.labelMedium),
            AnchorSpacing.verticalSpaceXL,

            // Spacing Section
            Text('Spacing System', style: AnchorTypography.headlineSmall),
            AnchorSpacing.verticalSpaceMD,
            Text(
              '8px-based spacing system',
              style: AnchorTypography.bodyMedium.copyWith(
                color: AnchorColors.gray600,
              ),
            ),
            AnchorSpacing.verticalSpaceHuge,
          ],
        ),
      ),
    );
  }
}

class _ColorBox extends StatelessWidget {
  final Color color;
  final String label;

  const _ColorBox({
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: color,
            borderRadius: AnchorSpacing.radiusSM,
            border: Border.all(
              color: AnchorColors.gray200,
              width: 1,
            ),
          ),
        ),
        AnchorSpacing.verticalSpaceXS,
        Text(
          label,
          style: AnchorTypography.labelSmall,
        ),
      ],
    );
  }
}
