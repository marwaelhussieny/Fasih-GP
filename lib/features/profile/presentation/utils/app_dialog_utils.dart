// lib/features/profile/presentation/utils/app_dialog_utils.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppDialogUtils {
  static void showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        final ThemeData theme = Theme.of(context);
        return Dialog(
          backgroundColor: theme.cardColor, // Themed background
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Padding(
            padding: EdgeInsets.all(24.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  color: theme.primaryColor, // Themed color
                ),
                SizedBox(height: 16.h),
                Text(
                  'جاري التحميل...', // Loading...
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.textTheme.bodyLarge?.color, // Themed text color
                    fontSize: 16.sp,
                  ) ?? const TextStyle(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static Future<bool> showDiscardChangesDialog(BuildContext context) async {
    final ThemeData theme = Theme.of(context);
    final Color textColor = theme.textTheme.bodyLarge!.color!;
    final Color primaryColor = theme.primaryColor;

    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: theme.cardColor, // Themed background
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          title: Text(
            'تجاهل التغييرات؟', // Discard Changes?
            style: theme.textTheme.titleLarge?.copyWith(
              color: textColor,
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
            ) ?? const TextStyle(),
          ),
          content: Text(
            'هل أنت متأكد أنك تريد تجاهل التغييرات التي لم يتم حفظها؟', // Are you sure you want to discard unsaved changes?
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.hintColor, // Muted text color
              fontSize: 14.sp,
            ) ?? const TextStyle(),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // Don't discard
              },
              child: Text(
                'إلغاء', // Cancel
                style: theme.textButtonTheme.style?.textStyle?.resolve({})?.copyWith(
                  color: textColor, // Themed text color
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // Discard
              },
              child: Text(
                'تجاهل', // Discard
                style: theme.textButtonTheme.style?.textStyle?.resolve({})?.copyWith(
                  color: primaryColor, // Themed primary color
                ),
              ),
            ),
          ],
        );
      },
    ) ?? false; // Return false if dialog is dismissed
  }
}
