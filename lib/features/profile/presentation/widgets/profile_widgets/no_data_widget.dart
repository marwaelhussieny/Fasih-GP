// lib/features/profile/presentation/widgets/no_data_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:grad_project/core/navigation/app_routes.dart'; // For navigation to login

class ProfileNoDataWidget extends StatelessWidget {
  const ProfileNoDataWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color textColor = theme.textTheme.bodyLarge!.color!;
    final Color mutedTextColor = theme.hintColor;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person_off_outlined,
            size: 64.r, // Responsive size
            color: theme.iconTheme.color?.withOpacity(0.5), // Themed icon color with opacity
          ),
          SizedBox(height: 16.h),
          Text(
            'لا توجد بيانات للملف الشخصي.', // No profile data available.
            style: theme.textTheme.titleMedium?.copyWith(
              fontSize: 16.sp, // Responsive font size
              color: textColor, // Themed text color
            ) ?? const TextStyle(), // Fallback
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8.h),
          Text(
            'يرجى تسجيل الدخول أو إنشاء حساب جديد.', // Please log in or create a new account.
            style: theme.textTheme.bodyMedium?.copyWith(
              fontSize: 14.sp, // Responsive font size
              color: mutedTextColor, // Muted text color
            ) ?? const TextStyle(), // Fallback
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24.h),
          ElevatedButton(
            onPressed: () => Navigator.pushReplacementNamed(context, AppRoutes.login),
            child: Text(
              'تسجيل الدخول', // Login
              style: theme.elevatedButtonTheme.style?.textStyle?.resolve({})?.copyWith(
                color: theme.colorScheme.onPrimary, // Themed text color on button
              ),
            ),
            style: theme.elevatedButtonTheme.style, // Use themed button style
          ),
        ],
      ),
    );
  }
}