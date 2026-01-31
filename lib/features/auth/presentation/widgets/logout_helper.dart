// lib/features/auth/presentation/widgets/logout_helper.dart

import 'package:flutter/material.dart';
import 'logout_dialog.dart';

class LogoutHelper {
  // Show logout confirmation dialog
  static Future<void> showLogoutDialog(BuildContext context) async {
    return LogoutDialog.show(context);
  }

  // Quick logout without confirmation (use with caution)
  static Future<void> quickLogout(BuildContext context) async {
    // Implementation would go here - typically you'd want confirmation
    // This is just a placeholder for direct logout scenarios
    await LogoutDialog.show(context);
  }

  // Logout button widget that can be used anywhere
  static Widget logoutButton({
    required BuildContext context,
    String? text,
    IconData? icon,
    Color? color,
    VoidCallback? onPressed,
  }) {
    return TextButton.icon(
      onPressed: onPressed ?? () => showLogoutDialog(context),
      icon: Icon(
        icon ?? Icons.logout_rounded,
        color: color ?? Theme.of(context).colorScheme.error,
      ),
      label: Text(
        text ?? 'تسجيل الخروج',
        style: TextStyle(
          color: color ?? Theme.of(context).colorScheme.error,
          fontFamily: 'Tajawal',
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  // Logout list tile for drawer/settings
  static Widget logoutListTile({
    required BuildContext context,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(
        Icons.logout_rounded,
        color: Theme.of(context).colorScheme.error,
      ),
      title: Text(
        'تسجيل الخروج',
        style: TextStyle(
          color: Theme.of(context).colorScheme.error,
          fontFamily: 'Tajawal',
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap ?? () => showLogoutDialog(context),
    );
  }
}