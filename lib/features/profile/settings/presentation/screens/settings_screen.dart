// lib/features/profile/settings/presentation/screens/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:grad_project/core/navigation/app_routes.dart';
import 'package:grad_project/core/theme/theme_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    // Theme colors
    final Color backgroundColor = Theme.of(context).scaffoldBackgroundColor;
    final Color cardColor = Theme.of(context).cardColor;
    final Color textColor = Theme.of(context).textTheme.bodyMedium!.color!;
    final Color appBarIconColor = Theme.of(context).appBarTheme.iconTheme!.color!;
    final Color appBarTextColor = Theme.of(context).appBarTheme.titleTextStyle!.color!;
    final Color primaryIconColor = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          'الإعدادات',
          style: TextStyle(
            color: appBarTextColor,
            fontFamily: 'Tajwal',
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: appBarIconColor),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                spreadRadius: 0,
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 20),
              _buildSettingsItem(
                context,
                textColor: textColor,
                iconColor: primaryIconColor,
                icon: Icons.person,
                title: 'الحساب الشخصي',
                onTap: () {
                  Navigator.of(context).pushNamed(AppRoutes.personalAccount);
                },
              ),
              _buildDivider(),
              _buildSettingsItem(
                context,
                textColor: textColor,
                iconColor: primaryIconColor,
                icon: Icons.notifications,
                title: 'الاشعارات',
                onTap: () {
                  Navigator.of(context).pushNamed(AppRoutes.notifications);
                },
              ),
              _buildDivider(),
              _buildSettingsItem(
                context,
                textColor: textColor,
                iconColor: primaryIconColor,
                icon: Icons.accessibility,
                title: 'تسهيلات الاستخدام',
                onTap: () {
                  Navigator.of(context).pushNamed(AppRoutes.accessibility);
                },
              ),
              _buildDivider(),
              _buildSettingsItem(
                context,
                textColor: textColor,
                iconColor: primaryIconColor,
                icon: Icons.security,
                title: 'الأمن',
                onTap: () {
                  Navigator.of(context).pushNamed(AppRoutes.security);
                },
              ),
              _buildDivider(),
              // Night Mode Toggle
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  children: [
                    Switch(
                      value: themeProvider.isDarkMode,
                      onChanged: (bool value) {
                        themeProvider.toggleTheme(value);
                      },
                    ),
                    const Spacer(),
                    Text(
                      'الوضع الليلي',
                      style: TextStyle(
                        fontSize: 16,
                        color: textColor,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Tajwal',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: primaryIconColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.nightlight_round,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
              _buildDivider(),
              _buildSettingsItem(
                context,
                textColor: textColor,
                iconColor: primaryIconColor,
                icon: Icons.info,
                title: 'عن التطبيق',
                onTap: () {
                  Navigator.of(context).pushNamed(AppRoutes.aboutApp);
                },
              ),
              const SizedBox(height: 20),
              // Logout Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        _showLogoutConfirmationDialog(context);
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                      ),
                      child: const Text(
                        'تسجيل الخروج',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.red,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Tajwal',
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.logout,
                        color: Colors.red,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsItem(BuildContext context, {
    required Color textColor,
    required Color iconColor,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Icon(
              Icons.arrow_back_ios,
              size: 16,
              color: textColor.withOpacity(0.5),
            ),
            const Spacer(),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                color: textColor,
                fontWeight: FontWeight.w500,
                fontFamily: 'Tajwal',
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Divider(
        height: 1,
        thickness: 0.5,
        color: Colors.grey.withOpacity(0.3),
      ),
    );
  }

  void _showLogoutConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        final Color dialogBackgroundColor = Theme.of(context).dialogBackgroundColor;
        final Color dialogTextColor = Theme.of(context).textTheme.bodyMedium!.color!;

        return AlertDialog(
          backgroundColor: dialogBackgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Text(
            'تسجيل الخروج',
            style: TextStyle(
              color: dialogTextColor,
              fontFamily: 'Tajwal',
            ),
          ),
          content: Text(
            'هل أنت متأكد أنك تريد تسجيل الخروج؟',
            style: TextStyle(
              color: dialogTextColor.withOpacity(0.8),
              fontFamily: 'Tajwal',
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'إلغاء',
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontFamily: 'Tajwal',
                ),
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: const Text(
                'تسجيل الخروج',
                style: TextStyle(
                  color: Colors.red,
                  fontFamily: 'Tajwal',
                ),
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                Navigator.of(context).pushNamedAndRemoveUntil(
                  AppRoutes.login,
                      (route) => false,
                );
              },
            ),
          ],
        );
      },
    );
  }
}