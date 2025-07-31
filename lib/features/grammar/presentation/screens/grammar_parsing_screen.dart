// lib/features/grammar/presentation/screens/grammar_parsing_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
// Removed direct color imports

class GrammarParsingScreen extends StatefulWidget {
  const GrammarParsingScreen({Key? key}) : super(key: key);

  @override
  State<GrammarParsingScreen> createState() => _GrammarParsingScreenState();
}

class _GrammarParsingScreenState extends State<GrammarParsingScreen> with TickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  List<Map<String, String>> _results = []; // To store parsing results
  bool _isLoading = false;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _performParsing() async {
    if (_textController.text.trim().isEmpty) {
      _showSnackBar('الرجاء إدخال نص للإعراب.'); // Please enter text for parsing.
      return;
    }

    setState(() {
      _isLoading = true;
      _results = []; // Clear previous results
    });

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    // Dummy parsing results
    setState(() {
      _results = [
        {'word': 'البيت', 'type': 'اسم', 'details': 'مبتدأ مرفوع وعلامة رفعه الضمة الظاهرة على آخره.'},
        {'word': 'جميل', 'type': 'صفة', 'details': 'خبر مرفوع وعلامة رفعه الضمة الظاهرة على آخره.'},
        {'word': 'جداً', 'type': 'ظرف', 'details': 'ظرف زمان منصوب وعلامة نصبه الفتحة الظاهرة على آخره.'},
      ];
      _isLoading = false;
      _animationController.forward(from: 0.0); // Start animation for new results
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
          'الإعراب', // Parsing
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
              'أدخل جملة للإعراب:', // Enter a sentence for parsing:
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
              maxLines: 3,
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
              onPressed: _isLoading ? null : _performParsing,
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
                'إعراب الجملة', // Parse Sentence
                style: textTheme.titleMedium?.copyWith(
                  color: colorScheme.onPrimary, // Use onPrimary
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 30.h),
            Expanded(
              child: _results.isEmpty && !_isLoading
                  ? Center(
                child: Text(
                  'نتائج الإعراب ستظهر هنا.', // Parsing results will appear here.
                  textAlign: TextAlign.center,
                  style: textTheme.bodyLarge?.copyWith(
                    color: isDarkMode ? colorScheme.onSurface.withOpacity(0.54) : Colors.black54, // Replaced secondaryTextColor
                    fontSize: 16.sp,
                  ),
                ),
              )
                  : ListView.builder(
                itemCount: _results.length,
                itemBuilder: (context, index) {
                  final result = _results[index];
                  return FadeTransition(
                    opacity: _animationController,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.5),
                        end: Offset.zero,
                      ).animate(CurvedAnimation(
                        parent: _animationController,
                        curve: Interval(
                          index / _results.length,
                          1.0,
                          curve: Curves.easeOut,
                        ),
                      )),
                      child: _buildParsingResultCard(
                        word: result['word']!,
                        type: result['type']!,
                        details: result['details']!,
                        context: context,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParsingResultCard({
    required String word,
    required String type,
    required String details,
    required BuildContext context,
  }) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final TextTheme textTheme = theme.textTheme;
    final bool isDarkMode = theme.brightness == Brightness.dark;

    Color cardColor = isDarkMode ? colorScheme.surface : Colors.white; // Use surface/white
    Color accentColor = colorScheme.primary; // Use theme primary

    return Container(
      margin: EdgeInsets.only(bottom: 15.h),
      padding: EdgeInsets.all(15.w),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(15.r),
        boxShadow: [
          BoxShadow(
            color: (isDarkMode ? Colors.black : Colors.grey).withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(
          color: accentColor.withOpacity(0.3),
          width: 1.w,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                word,
                style: textTheme.titleLarge?.copyWith(
                  color: accentColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 20.sp,
                ),
              ),
              SizedBox(width: 15.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  type,
                  style: textTheme.titleSmall?.copyWith(
                    color: accentColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 18.sp,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(15.w),
            decoration: BoxDecoration(
              color: (isDarkMode ? Colors.white : accentColor).withOpacity(0.05), // Use accentColor
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Text(
              details,
              style: textTheme.bodyMedium?.copyWith(
                color: isDarkMode ? colorScheme.onSurface.withOpacity(0.7) : Colors.black87, // Replaced secondaryTextColor
                fontSize: 15.sp,
                height: 1.4,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
