// lib/features/profile/presentation/widgets/profile_app_bar.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProfileAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onSettingsPressed;

  const ProfileAppBar({
    Key? key,
    required this.onSettingsPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return AppBar(
      backgroundColor: Colors.transparent, // Transparent to show scaffold background
      elevation: 0, // No shadow
      title: Text(
        'الحساب', // Account
        style: theme.appBarTheme.titleTextStyle?.copyWith(
          fontSize: 20.sp, // Responsive font size
          fontWeight: FontWeight.w700,
        ) ?? TextStyle( // Fallback if titleTextStyle is null
          fontSize: 20.sp,
          fontWeight: FontWeight.w700,
          color: theme.textTheme.bodyLarge?.color,
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: Icon(
            Icons.settings,
            color: theme.appBarTheme.iconTheme?.color ?? theme.iconTheme.color, // Themed icon color
            size: 24.r, // Responsive size
          ),
          onPressed: onSettingsPressed,
        ),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(AppBar().preferredSize.height);
}