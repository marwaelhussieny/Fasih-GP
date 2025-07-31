// lib/features/profile/presentation/widgets/profile_widgets/error_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProfileErrorWidget extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const ProfileErrorWidget({
    Key? key,
    required this.error,
    required this.onRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color textColor = theme.textTheme.bodyLarge!.color!;
    final Color errorColor = theme.colorScheme.error;
    final Color primaryColor = theme.primaryColor;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64.r, // Responsive size
              color: errorColor, // Themed error color
            ),
            SizedBox(height: 16.h),
            Text(
              'حدث خطأ في تحميل البيانات', // Error loading data
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge?.copyWith(
                fontSize: 18.sp, // Responsive font size
                fontWeight: FontWeight.w600,
                color: textColor, // Themed text color
              ) ?? const TextStyle(), // Fallback
            ),
            SizedBox(height: 8.h),
            Text(
              error,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontSize: 14.sp, // Responsive font size
                color: theme.hintColor, // Muted text color
              ) ?? const TextStyle(), // Fallback
            ),
            SizedBox(height: 24.h),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: Icon(Icons.refresh, size: 18.r, color: theme.colorScheme.onPrimary), // Themed icon color
              label: Text(
                'إعادة المحاولة', // Retry
                style: theme.elevatedButtonTheme.style?.textStyle?.resolve({})?.copyWith(
                  fontSize: 14.sp, // Responsive font size
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: theme.elevatedButtonTheme.style?.copyWith(
                backgroundColor: MaterialStateProperty.all(primaryColor), // Themed button background
                foregroundColor: MaterialStateProperty.all(theme.colorScheme.onPrimary), // Themed button text color
              ),
            ),
          ],
        ),
      ),
    );
  }
}
