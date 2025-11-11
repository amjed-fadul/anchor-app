import 'package:flutter/material.dart';
import '../../../design_system/design_system.dart';

/// Login screen
///
/// Allows existing users to sign in with:
/// - Email and password
/// - Google OAuth
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Log In'),
      ),
      body: Center(
        child: Text(
          'Login Screen',
          style: AnchorTypography.headlineSmall,
        ),
      ),
    );
  }
}
