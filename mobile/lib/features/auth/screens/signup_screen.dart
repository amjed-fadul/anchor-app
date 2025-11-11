import 'package:flutter/material.dart';
import '../../../design_system/design_system.dart';

/// Sign up screen
///
/// Allows users to create a new account with:
/// - Email and password
/// - Google OAuth
class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up'),
      ),
      body: Center(
        child: Text(
          'Signup Screen',
          style: AnchorTypography.headlineSmall,
        ),
      ),
    );
  }
}
