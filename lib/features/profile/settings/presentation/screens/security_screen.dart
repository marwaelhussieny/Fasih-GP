// lib/features/profile/settings/security_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:grad_project/core/navigation/app_routes.dart';
import 'package:grad_project/features/profile/presentation/providers/user_provider.dart';

class SecurityScreen extends StatefulWidget {
  const SecurityScreen({Key? key}) : super(key: key);

  @override
  State<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen> {
  @override
  void initState() {
    super.initState();
    // Load preferences when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      if (userProvider.preferences == null) {
        userProvider.loadPreferences();
      }
    });
  }

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
      body: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          final preferences = userProvider.preferences;

          // Show loading indicator if preferences are loading
          if (userProvider.isLoading && preferences == null) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // Show error if failed to load preferences
          if (userProvider.error != null && preferences == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'خطأ في تحميل الإعدادات',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    userProvider.error!,
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => userProvider.loadPreferences(),
                    child: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
            );
          }

          return ListView(
            children: [
              ListTile(
                title: const Text('تذكرني'), // Remember Me
                trailing: Switch(
                  value: preferences?.rememberMe ?? true,
                  onChanged: userProvider.isLoading ? null : (value) => _updateRememberMe(context, value),
                ),
              ),
              _buildSecurityTile(
                context,
                title: 'إعادة ضبط كلمة المرور', // Reset Password
                onTap: () {
                  // Navigate to forgot password screen
                  Navigator.of(context).pushNamed(AppRoutes.forgotPassword);
                },
              ),
              _buildSecurityTile(
                context,
                title: 'تغيير البريد الالكتروني', // Change Email
                onTap: () {
                  _showChangeEmailDialog(context);
                },
              ),
              _buildSecurityTile(
                context,
                title: 'تغيير كلمة المرور', // Change Password
                onTap: () {
                  _showChangePasswordDialog(context);
                },
              ),
            ],
          );
        },
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

  Future<void> _updateRememberMe(BuildContext context, bool value) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    try {
      await userProvider.updateGeneralPreference('rememberMe', value);

      if (!mounted) return;

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم تحديث إعداد "تذكرني" بنجاح'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ في تحديث الإعدادات: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _showChangeEmailDialog(BuildContext context) {
    final TextEditingController emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('تغيير البريد الإلكتروني'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('أدخل البريد الإلكتروني الجديد:'),
              const SizedBox(height: 16),
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'البريد الإلكتروني الجديد',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () {
                if (emailController.text.isNotEmpty) {
                  Navigator.pop(context);
                  _changeEmail(context, emailController.text);
                }
              },
              child: const Text('تغيير'),
            ),
          ],
        );
      },
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    final TextEditingController oldPasswordController = TextEditingController();
    final TextEditingController newPasswordController = TextEditingController();
    final TextEditingController confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('تغيير كلمة المرور'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: oldPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'كلمة المرور الحالية',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: newPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'كلمة المرور الجديدة',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: confirmPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'تأكيد كلمة المرور الجديدة',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () {
                if (oldPasswordController.text.isNotEmpty &&
                    newPasswordController.text.isNotEmpty &&
                    newPasswordController.text == confirmPasswordController.text) {
                  Navigator.pop(context);
                  _changePassword(context, oldPasswordController.text, newPasswordController.text);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('تأكد من صحة البيانات المدخلة'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text('تغيير'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _changeEmail(BuildContext context, String newEmail) async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      await userProvider.changeEmail(newEmail);

      if (!mounted) return;

      Navigator.pop(context); // Close loading dialog

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم تغيير البريد الإلكتروني بنجاح'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      Navigator.pop(context); // Close loading dialog

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ في تغيير البريد الإلكتروني: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _changePassword(BuildContext context, String oldPassword, String newPassword) async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      await userProvider.changePassword(oldPassword, newPassword);

      if (!mounted) return;

      Navigator.pop(context); // Close loading dialog

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم تغيير كلمة المرور بنجاح'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      Navigator.pop(context); // Close loading dialog

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ في تغيير كلمة المرور: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
}