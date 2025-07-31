// lib/features/profile/settings/security_screen.dart
import 'package:flutter/material.dart';
import 'package:grad_project/core/navigation/app_routes.dart'; // Import app routes for navigation

class SecurityScreen extends StatefulWidget {
  const SecurityScreen({Key? key}) : super(key: key);

  @override
  State<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen> {
  bool _rememberMe = true; // State for 'Remember Me' switch

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الأمن'), // Security
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop(); // Go back to SettingsScreen
          },
        ),
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text('تذكرني'), // Remember Me
            trailing: Switch(
              value: _rememberMe,
              onChanged: (value) {
                setState(() {
                  _rememberMe = value;
                  // TODO: Save preference (e.g., via a provider)
                });
              },
            ),
          ),
          _buildSecurityTile(
            context,
            title: 'إعادة ضبط كلمة المرور', // Reset Password
            onTap: () {
              // Navigate to a password reset screen, possibly ForgotPasswordScreen or a dedicated NewPasswordScreen
              // You might need to pass arguments if ForgotPasswordScreen requires an email
              Navigator.of(context).pushNamed(AppRoutes.forgotPassword); // Or AppRoutes.newPassword
            },
          ),
          _buildSecurityTile(
            context,
            title: 'تغيير البريد الالكتروني', // Change Email
            onTap: () {
              // TODO: Navigate to a change email screen
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityTile(BuildContext context, {
    required String title,
    VoidCallback? onTap,
  }) {
    return ListTile(
      title: Text(title),
      trailing: onTap != null ? const Icon(Icons.arrow_forward_ios, size: 16) : null,
      onTap: onTap,
    );
  }
}