// lib/features/grammar/presentation/screens/plural_finder_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
// Removed direct color imports

class PluralFinderScreen extends StatefulWidget {
  const PluralFinderScreen({Key? key}) : super(key: key);

  @override
  State<PluralFinderScreen> createState() => _PluralFinderScreenState();
}

class _PluralFinderScreenState extends State<PluralFinderScreen> {
  final TextEditingController _textController = TextEditingController();
  String _pluralResult = '';
  bool _isLoading = false;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _findPlural() async {
    setState(() {
      _isLoading = true;
      _pluralResult = ''; // Clear previous result
    });

    final inputText = _textController.text.trim();
    if (inputText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('الرجاء إدخال كلمة للبحث عن الجمع.', style: TextStyle(fontFamily: 'Tajawal', fontSize: 14.sp))),
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    // Dummy plural result
    setState(() {
      _pluralResult = 'أقلام'; // Example plural for 'قلم'
      _isLoading = false;
    });
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message, style: Theme.of(context).textTheme.bodyMedium)),
    );
  }

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
          'البحث عن الجمع', // Plural Finder
          style: textTheme.headlineSmall?.copyWith(
            color: theme.appBarTheme.titleTextStyle?.color,
            fontSize: 24.sp,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'أدخل كلمة مفردة لإيجاد جمعها:', // Enter a singular word to find its plural:
              style: textTheme.titleMedium?.copyWith(
                color: isDarkMode ? colorScheme.onBackground : colorScheme.primary, // Use onBackground/primary
                fontSize: 18.sp,
              ),
              textAlign: TextAlign.right,
            ),
            SizedBox(height: 15.h),
            TextField(
              controller: _textController,
              textAlign: TextAlign.right,
              style: textTheme.bodyMedium?.copyWith(
                color: isDarkMode ? colorScheme.onSurface : colorScheme.onBackground, // Use onSurface/onBackground
                fontSize: 16.sp,
              ),
              decoration: InputDecoration(
                hintText: 'اكتب هنا...', // Write here...
                hintStyle: textTheme.bodyMedium?.copyWith(
                  color: isDarkMode ? colorScheme.onSurface.withOpacity(0.5) : Colors.black54, // Replaced secondaryTextColor
                  fontSize: 16.sp,
                ),
                filled: true,
                fillColor: isDarkMode ? colorScheme.surface : Colors.white, // Use surface/white
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(
                    color: isDarkMode ? colorScheme.outline : colorScheme.outline, // Use theme outline
                    width: 1.w,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(
                    color: colorScheme.primary, // Use theme primary
                    width: 2.w,
                  ),
                ),
              ),
            ),
            SizedBox(height: 20.h),
            ElevatedButton(
              onPressed: _isLoading ? null : _findPlural,
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary, // Use theme primary
                foregroundColor: colorScheme.onPrimary, // Use theme onPrimary
                padding: EdgeInsets.symmetric(vertical: 15.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                elevation: 5,
                shadowColor: colorScheme.primary.withOpacity(0.3), // Use primary
              ),
              child: _isLoading
                  ? SizedBox(
                width: 24.w,
                height: 24.h,
                child: CircularProgressIndicator(
                  color: colorScheme.onPrimary, // Use onPrimary
                  strokeWidth: 2.w,
                ),
              )
                  : Text(
                'البحث عن الجمع', // Find Plural
                style: textTheme.titleMedium?.copyWith(
                  color: colorScheme.onPrimary, // Use onPrimary
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 30.h),
            Expanded(
              child: _pluralResult.isEmpty && !_isLoading
                  ? Center(
                child: Text(
                  'سيظهر الجمع الذي تم إيجاده هنا.', // Found plural will appear here.
                  textAlign: TextAlign.center,
                  style: textTheme.bodyLarge?.copyWith(
                    color: isDarkMode ? colorScheme.onSurface.withOpacity(0.54) : Colors.black54, // Replaced secondaryTextColor
                    fontSize: 16.sp,
                  ),
                ),
              )
                  : Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: isDarkMode ? colorScheme.surface : Colors.white, // Use surface/white
                  borderRadius: BorderRadius.circular(12.r),
                  boxShadow: [
                    BoxShadow(
                      color: (isDarkMode ? Colors.black : Colors.grey).withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(
                    color: isDarkMode ? colorScheme.tertiary.withOpacity(0.2) : colorScheme.primary.withOpacity(0.2), // Use tertiary/primary
                    width: 1.w,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'الجمع:', // Plural:
                      style: textTheme.titleMedium?.copyWith(
                        color: isDarkMode ? colorScheme.tertiary : colorScheme.primary, // Use tertiary/primary
                        fontWeight: FontWeight.bold,
                        fontSize: 16.sp,
                      ),
                      textAlign: TextAlign.right,
                    ),
                    SizedBox(height: 8.h),
                    Center(
                      child: Text(
                        _pluralResult,
                        style: textTheme.headlineMedium?.copyWith(
                          color: isDarkMode ? colorScheme.onSurface : colorScheme.onBackground, // Use onSurface/onBackground
                          fontSize: 24.sp,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
