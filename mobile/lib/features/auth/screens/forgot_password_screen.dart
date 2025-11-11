import 'package:flutter/material.dart';
import '../../../design_system/design_system.dart';

/// Forgot password screen
///
/// Allows users to reset their password by:
/// - Entering their email
/// - Receiving a reset link via email
class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reset Password'),
      ),
      body: Center(
        child: Text(
          'Forgot Password Screen',
          style: AnchorTypography.headlineSmall,
        ),
      ),
    );
  }
}
