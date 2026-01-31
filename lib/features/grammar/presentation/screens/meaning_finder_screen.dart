// lib/features/grammar/presentation/screens/meaning_finder_screen.dart - DEMO MODE

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MeaningFinderScreen extends StatefulWidget {
  const MeaningFinderScreen({Key? key}) : super(key: key);

  @override
  State<MeaningFinderScreen> createState() => _MeaningFinderScreenState();
}

class _MeaningFinderScreenState extends State<MeaningFinderScreen>
    with TickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  late AnimationController _animationController;
  late AnimationController _resultAnimationController;

  bool isLoading = false;
  bool isServiceOnline = true; // Always show as online for demo
  String meaning = '';

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _resultAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Auto-load demo data for screenshots
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDemoData();
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _animationController.dispose();
    _resultAnimationController.dispose();
    super.dispose();
  }

  void _loadDemoData() {
    setState(() {
      _textController.text = 'كتاب';
      meaning = 'مُصْحَف';
    });
    _resultAnimationController.forward();
  }

  Future<void> _analyzeMeaning() async {
    if (_textController.text.trim().isEmpty) {
      _showSnackBar('الرجاء إدخال كلمة لتحليل المعنى.', Colors.orange);
      return;
    }

    setState(() {
      isLoading = true;
      meaning = '';
    });

    // Simulate processing delay
    await Future.delayed(const Duration(milliseconds: 1200));

    // Simple meaning mapping for demo
    String inputWord = _textController.text.trim();
    String simpleMeaning = _getSimpleMeaning(inputWord);

    setState(() {
      meaning = simpleMeaning;
      isLoading = false;
    });

    _resultAnimationController.forward(from: 0.0);
    _showSnackBar('تم تحليل المعنى بنجاح!', Colors.green);
  }

  String _getSimpleMeaning(String word) {
    // Simple demo meaning mapping
    final meaningMap = {
      'كتاب': 'مُصْحَف',
      'بيت': 'منزل',
      'سيارة': 'عربة',
      'مدرسة': 'معهد',
      'طالب': 'دارس',
      'معلم': 'مُدرِّس',
      'جميل': 'حسن',
      'كبير': 'عظيم',
      'صغير': 'ضئيل',
      'سريع': 'عاجل',
    };

    return meaningMap[word] ?? 'غير متوفر';
  }

  void _showSnackBar(String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontFamily: 'Tajawal'),
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final TextTheme textTheme = theme.textTheme;
    final bool isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: colorScheme.background,
      body: Stack(
        children: [
          // Faded background logo
          Positioned.fill(
            child: Opacity(
              opacity: 0.05,
              child: Center(
                child: Icon(
                  Icons.lightbulb_outline_rounded,
                  size: 200.r,
                  color: colorScheme.primary,
                ),
              ),
            ),
          ),

          // Main content
          Column(
            children: [
              // Custom AppBar
              SafeArea(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.arrow_back_ios_new,
                          color: theme.appBarTheme.iconTheme?.color,
                          size: 22.r,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Expanded(
                        child: Text(
                          'تحليل المعنى',
                          style: textTheme.headlineSmall?.copyWith(
                            color: theme.appBarTheme.titleTextStyle?.color,
                            fontSize: 24.sp,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      // Service status indicator - always online for demo
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6.w,
                              height: 6.h,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              'متصل',
                              style: TextStyle(
                                fontSize: 10.sp,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(20.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header Card
                      _buildHeaderCard(colorScheme, textTheme, isDarkMode),

                      SizedBox(height: 20.h),

                      // Input Section
                      _buildInputSection(colorScheme, textTheme, isDarkMode),

                      SizedBox(height: 20.h),

                      // Action Button
                      _buildActionButton(colorScheme, textTheme),

                      SizedBox(height: 30.h),

                      // Results Section
                      _buildResultsSection(colorScheme, textTheme, isDarkMode),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderCard(ColorScheme colorScheme, TextTheme textTheme, bool isDarkMode) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDarkMode
              ? [colorScheme.primary.withOpacity(0.2), colorScheme.primary.withOpacity(0.1)]
              : [colorScheme.primary.withOpacity(0.1), colorScheme.primary.withOpacity(0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: colorScheme.primary.withOpacity(0.2),
          width: 1.5.w,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Icon(
              Icons.lightbulb_outline_rounded,
              color: colorScheme.primary,
              size: 28.r,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'تحليل المعنى بـ E3rbly',
                  style: textTheme.titleMedium?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 16.sp,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'أدخل كلمة لاستكشاف معناها بالتفصيل',
                  style: textTheme.bodySmall?.copyWith(
                    color: isDarkMode ? colorScheme.onBackground.withOpacity(0.7) : Colors.black54,
                    fontSize: 12.sp,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputSection(ColorScheme colorScheme, TextTheme textTheme, bool isDarkMode) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: isDarkMode ? colorScheme.surface : Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.2),
          width: 1.w,
        ),
        boxShadow: [
          BoxShadow(
            color: (isDarkMode ? Colors.black : Colors.grey).withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            'أدخل الكلمة لتحليل المعنى:',
            style: textTheme.titleMedium?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.bold,
              fontSize: 16.sp,
            ),
          ),
          SizedBox(height: 15.h),
          TextField(
            controller: _textController,
            textAlign: TextAlign.right,
            style: textTheme.bodyMedium?.copyWith(
              color: isDarkMode ? colorScheme.onSurface : colorScheme.onBackground,
              fontSize: 16.sp,
              height: 1.5,
            ),
            decoration: InputDecoration(
              hintText: 'مثال: كتاب، حكمة، علم...',
              hintStyle: textTheme.bodyMedium?.copyWith(
                color: isDarkMode ? colorScheme.onSurface.withOpacity(0.5) : Colors.black54,
                fontSize: 14.sp,
              ),
              filled: true,
              fillColor: isDarkMode
                  ? colorScheme.background.withOpacity(0.5)
                  : colorScheme.background,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15.r),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15.r),
                borderSide: BorderSide(
                  color: colorScheme.outline.withOpacity(0.3),
                  width: 1.w,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15.r),
                borderSide: BorderSide(
                  color: colorScheme.primary,
                  width: 2.w,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(ColorScheme colorScheme, TextTheme textTheme) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colorScheme.primary, colorScheme.primary.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: isLoading ? null : _analyzeMeaning,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          padding: EdgeInsets.symmetric(vertical: 18.h),
        ),
        child: isLoading
            ? Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 24.w,
              height: 24.h,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2.w,
              ),
            ),
            SizedBox(width: 12.w),
            Text(
              'جاري التحليل...',
              style: textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        )
            : Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.lightbulb_outline_rounded,
              color: Colors.white,
              size: 24.r,
            ),
            SizedBox(width: 12.w),
            Text(
              'تحليل المعنى',
              style: textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsSection(ColorScheme colorScheme, TextTheme textTheme, bool isDarkMode) {
    if (meaning.isEmpty && !isLoading) {
      return _buildEmptyState(colorScheme, textTheme, isDarkMode);
    }

    return FadeTransition(
      opacity: _resultAnimationController,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.3),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: _resultAnimationController,
          curve: Curves.easeOut,
        )),
        child: Container(
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDarkMode
                  ? [colorScheme.secondary.withOpacity(0.2), colorScheme.secondary.withOpacity(0.1)]
                  : [colorScheme.secondary.withOpacity(0.1), colorScheme.secondary.withOpacity(0.05)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(
              color: colorScheme.secondary.withOpacity(0.3),
              width: 1.5.w,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'المعنى:',
                    style: textTheme.titleLarge?.copyWith(
                      color: colorScheme.secondary,
                      fontWeight: FontWeight.bold,
                      fontSize: 18.sp,
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Icon(
                    Icons.lightbulb,
                    color: colorScheme.secondary,
                    size: 24.r,
                  ),
                ],
              ),
              SizedBox(height: 15.h),
              if (meaning.isNotEmpty)
                Center(
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 24.w,
                      vertical: 16.h,
                    ),
                    decoration: BoxDecoration(
                      color: isDarkMode
                          ? colorScheme.background.withOpacity(0.5)
                          : Colors.white.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(15.r),
                      border: Border.all(
                        color: colorScheme.secondary.withOpacity(0.3),
                        width: 2.w,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: colorScheme.secondary.withOpacity(0.2),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Text(
                      meaning,
                      style: textTheme.titleLarge?.copyWith(
                        color: colorScheme.secondary,
                        fontWeight: FontWeight.bold,
                        fontSize: 22.sp,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(ColorScheme colorScheme, TextTheme textTheme, bool isDarkMode) {
    return Container(
      padding: EdgeInsets.all(40.w),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.lightbulb_outline_rounded,
              size: 60.r,
              color: colorScheme.primary.withOpacity(0.7),
            ),
          ),
          SizedBox(height: 20.h),
          Text(
            'المعنى سيظهر هنا',
            style: textTheme.bodyLarge?.copyWith(
              color: isDarkMode ? colorScheme.onSurface.withOpacity(0.54) : Colors.black54,
              fontSize: 16.sp,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8.h),
          Text(
            'أدخل كلمة واضغط على "تحليل المعنى" للبدء',
            style: textTheme.bodySmall?.copyWith(
              color: isDarkMode ? colorScheme.onSurface.withOpacity(0.4) : Colors.black38,
              fontSize: 14.sp,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}