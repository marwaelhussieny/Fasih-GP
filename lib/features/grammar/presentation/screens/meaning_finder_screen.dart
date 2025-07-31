// lib/features/grammar/presentation/screens/meaning_finder_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
// Removed direct color imports

class MeaningFinderScreen extends StatelessWidget {
  const MeaningFinderScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final TextTheme textTheme = theme.textTheme;
    final bool isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: colorScheme.background, // Use theme background color
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: theme.appBarTheme.iconTheme?.color,
            size: 22.r,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'المعنى', // Meaning
          style: textTheme.headlineSmall?.copyWith(
            color: theme.appBarTheme.titleTextStyle?.color,
            fontSize: 24.sp,
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.lightbulb_outline, // Icon for meaning/idea
                size: 80.r,
                color: isDarkMode ? colorScheme.tertiary : colorScheme.primary, // Use tertiary/primary
              ),
              SizedBox(height: 20.h),
              Text(
                'هذه شاشة البحث عن المعنى. يمكنك البدء في إضافة منطق الواجهة الخلفية هنا.', // This is the Meaning Finder screen. You can start adding backend logic here.
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium?.copyWith(
                  fontSize: 16.sp,
                  color: isDarkMode ? colorScheme.onBackground.withOpacity(0.7) : Colors.black87, // Replaced secondaryTextColor
                ),
              ),
              SizedBox(height: 40.h),
              // TODO: Add your UI elements for meaning finding (e.g., text input, search button, result display)
            ],
          ),
        ),
      ),
    );
  }
}
