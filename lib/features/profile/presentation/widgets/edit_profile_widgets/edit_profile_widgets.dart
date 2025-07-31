// lib/features/profile/presentation/widgets/edit_profile_widgets/edit_profile_widgets.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart'; // For accessing UserProvider
import 'package:grad_project/features/profile/presentation/providers/user_provider.dart'; // Import UserProvider

class EditProfileWidgets {
  // --- Loading State Widget ---
  static Widget buildLoadingState(ThemeData theme) {
    return Center(
      child: CircularProgressIndicator(
        color: theme.primaryColor, // Themed color
        strokeWidth: 3.w, // Responsive width
      ),
    );
  }

  // --- Error State Widget ---
  static Widget buildErrorState(ThemeData theme, UserProvider userProvider) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64.r, // Responsive size
              color: theme.colorScheme.error, // Themed error color
            ),
            SizedBox(height: 16.h),
            Text(
              'حدث خطأ في تحميل البيانات', // Error loading data
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge?.copyWith(
                fontSize: 18.sp, // Responsive font size
                fontWeight: FontWeight.w600,
                color: theme.textTheme.bodyLarge?.color, // Themed text color
              ) ?? const TextStyle(),
            ),
            SizedBox(height: 8.h),
            Text(
              userProvider.error ?? 'خطأ غير معروف', // Unknown error
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontSize: 14.sp, // Responsive font size
                color: theme.hintColor, // Muted text color
              ) ?? const TextStyle(),
            ),
            SizedBox(height: 24.h),
            ElevatedButton.icon(
              onPressed: () => userProvider.loadUser(), // Retry loading user
              icon: Icon(Icons.refresh, size: 18.r, color: theme.colorScheme.onPrimary), // Themed icon color
              label: Text(
                'إعادة المحاولة', // Retry
                style: theme.elevatedButtonTheme.style?.textStyle?.resolve({})?.copyWith(
                  fontSize: 14.sp, // Responsive font size
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: theme.elevatedButtonTheme.style?.copyWith(
                backgroundColor: MaterialStateProperty.all(theme.primaryColor), // Themed button background
                foregroundColor: MaterialStateProperty.all(theme.colorScheme.onPrimary), // Themed button text color
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- No Data State Widget ---
  static Widget buildNoDataState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person_off_outlined,
            size: 64.r, // Responsive size
            color: theme.iconTheme.color?.withOpacity(0.5), // Themed icon color
          ),
          SizedBox(height: 16.h),
          Text(
            'لا توجد بيانات للملف الشخصي.', // No profile data available.
            style: theme.textTheme.titleMedium?.copyWith(
              fontSize: 16.sp, // Responsive font size
              color: theme.textTheme.bodyLarge?.color, // Themed text color
            ) ?? const TextStyle(),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8.h),
          Text(
            'يرجى تسجيل الدخول أو إنشاء حساب جديد.', // Please log in or create a new account.
            style: theme.textTheme.bodyMedium?.copyWith(
              fontSize: 14.sp, // Responsive font size
              color: theme.hintColor, // Muted text color
            ) ?? const TextStyle(),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24.h),
          // Note: If you have an AppRoutes.login, you can use it here.
          // For now, this button is a placeholder or can navigate back.
          ElevatedButton(
            onPressed: () {
              // Consider navigating to login or showing a message
              // Navigator.pushReplacementNamed(context, AppRoutes.login);
            },
            child: Text(
              'تسجيل الدخول', // Login
              style: theme.elevatedButtonTheme.style?.textStyle?.resolve({})?.copyWith(
                color: theme.colorScheme.onPrimary, // Themed text color
              ),
            ),
            style: theme.elevatedButtonTheme.style, // Use themed button style
          ),
        ],
      ),
    );
  }

  // --- Save Button Widget ---
  static Widget buildSaveButton({
    required BuildContext context,
    required bool isLoading,
    required VoidCallback onPressed,
  }) {
    final ThemeData theme = Theme.of(context);
    final Color primaryColor = theme.primaryColor;

    return SizedBox(
      width: double.infinity,
      height: 56.h, // Responsive height
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed, // Disable when loading
        style: theme.elevatedButtonTheme.style?.copyWith(
          backgroundColor: MaterialStateProperty.resolveWith<Color?>(
                (Set<MaterialState> states) {
              if (states.contains(MaterialState.disabled)) {
                return primaryColor.withOpacity(0.6); // Themed disabled color
              }
              return primaryColor; // Themed enabled color
            },
          ),
          foregroundColor: MaterialStateProperty.all(theme.colorScheme.onPrimary), // Themed text color
          shape: MaterialStateProperty.all(RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r), // Responsive border radius
          )),
          minimumSize: MaterialStateProperty.all(Size(double.infinity, 56.h)), // Ensure height is applied
        ),
        child: isLoading
            ? SizedBox(
          height: 20.r, // Responsive size
          width: 20.r, // Responsive size
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.onPrimary), // Themed color
          ),
        )
            : Text(
          'حفظ التغييرات', // Save Changes
          style: theme.elevatedButtonTheme.style?.textStyle?.resolve({})?.copyWith(
            fontSize: 18.sp, // Responsive font size
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}