// lib/features/grammar/presentation/screens/poetry_generation_screen.dart - COMPLETE BACKEND INTEGRATION

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:grad_project/features/grammar/presentation/providers/grammar_morphology_provider.dart';

class PoetryGenerationScreen extends StatefulWidget {
  const PoetryGenerationScreen({Key? key}) : super(key: key);

  @override
  State<PoetryGenerationScreen> createState() => _PoetryGenerationScreenState();
}

class _PoetryGenerationScreenState extends State<PoetryGenerationScreen>
    with TickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  late AnimationController _animationController;
  late AnimationController _resultAnimationController;
  int _selectedLines = 5; // Default number of lines

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

    // Check service status when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<GrammarMorphologyProvider>();
      provider.checkServiceStatus();
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _animationController.dispose();
    _resultAnimationController.dispose();
    super.dispose();
  }

  Future<void> _generatePoetry() async {
    if (_textController.text.trim().isEmpty) {
      _showSnackBar('الرجاء إدخال موضوع لتوليد الشعر.', Colors.orange);
      return;
    }

    final provider = context.read<GrammarMorphologyProvider>();

    // Check if E3rbly service is online first
    if (!provider.isServiceOnline) {
      await provider.checkServiceStatus();
      if (!provider.isServiceOnline) {
        _showSnackBar('خدمة E3rbly غير متوفرة حالياً. يرجى المحاولة لاحقاً.', Colors.red);
        return;
      }
    }

    // Generate poetry using the backend
    // TODO: Update the provider's generatePoetry method to accept the number of lines.
    // Assuming a default meter 'الطويل' since the selection is removed.
    await provider.generatePoetry(_textController.text.trim(), 'الطويل');

    if (provider.error == null) {
      _resultAnimationController.forward(from: 0.0);
      _showSnackBar(provider.getSuccessMessage('poetry'), Colors.green);
    } else {
      _showSnackBar(provider.getErrorMessage('poetry', provider.error!), Colors.red);
    }
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
                child: Image.asset(
                  'assets/images/app_logo.png', // Add your logo asset here
                  width: 200.w,
                  height: 200.h,
                  fit: BoxFit.contain,
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
                          'إنتاج الشعر',
                          style: textTheme.headlineSmall?.copyWith(
                            color: theme.appBarTheme.titleTextStyle?.color,
                            fontSize: 24.sp,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      // Service status indicator
                      Consumer<GrammarMorphologyProvider>(
                        builder: (context, provider, child) {
                          return Container(
                            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                            decoration: BoxDecoration(
                              color: provider.isServiceOnline ? Colors.green : Colors.red,
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
                                  provider.isServiceOnline ? 'متصل' : 'منقطع',
                                  style: TextStyle(
                                    fontSize: 10.sp,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // Content
              Expanded(
                child: Consumer<GrammarMorphologyProvider>(
                  builder: (context, provider, child) {
                    return SingleChildScrollView(
                      padding: EdgeInsets.all(20.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Header Card
                          _buildHeaderCard(colorScheme, textTheme, isDarkMode, provider),

                          SizedBox(height: 20.h),

                          // Input Section
                          _buildInputSection(colorScheme, textTheme, isDarkMode),

                          SizedBox(height: 20.h),

                          // Lines Selection
                          _buildLinesSelectionSection(colorScheme, textTheme, isDarkMode),

                          SizedBox(height: 20.h),

                          // Action Button
                          _buildActionButton(provider, colorScheme, textTheme),

                          SizedBox(height: 30.h),

                          // Results Section
                          _buildResultsSection(provider, colorScheme, textTheme, isDarkMode),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderCard(ColorScheme colorScheme, TextTheme textTheme, bool isDarkMode, GrammarMorphologyProvider provider) {
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
              Icons.auto_stories_rounded,
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
                  'مولد الشعر بـ E3rbly',
                  style: textTheme.titleMedium?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 16.sp,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'أدخل موضوعاً واختر البحر لتوليد الشعر',
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
            'أدخل الموضوع أو الفكرة:',
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
            maxLines: 3,
            style: textTheme.bodyMedium?.copyWith(
              color: isDarkMode ? colorScheme.onSurface : colorScheme.onBackground,
              fontSize: 16.sp,
              height: 1.5,
            ),
            decoration: InputDecoration(
              hintText: 'مثال: الحب، الوطن، الصداقة، الطبيعة...',
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

  Widget _buildLinesSelectionSection(ColorScheme colorScheme, TextTheme textTheme, bool isDarkMode) {
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
            'عدد الأبيات:',
            style: textTheme.titleMedium?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.bold,
              fontSize: 16.sp,
            ),
          ),
          SizedBox(height: 15.h),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedLines = 5;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 20.w),
                    decoration: BoxDecoration(
                      gradient: _selectedLines == 5
                          ? LinearGradient(
                        colors: [colorScheme.primary, colorScheme.primary.withOpacity(0.8)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                          : null,
                      color: _selectedLines != 5
                          ? (isDarkMode
                          ? colorScheme.background.withOpacity(0.5)
                          : colorScheme.background)
                          : null,
                      borderRadius: BorderRadius.circular(15.r),
                      border: Border.all(
                        color: _selectedLines == 5
                            ? colorScheme.primary
                            : colorScheme.outline.withOpacity(0.3),
                        width: 2.w,
                      ),
                      boxShadow: _selectedLines == 5
                          ? [
                        BoxShadow(
                          color: colorScheme.primary.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ]
                          : null,
                    ),
                    child: Column(
                      children: [
                        Text(
                          '5',
                          style: textTheme.headlineMedium?.copyWith(
                            color: _selectedLines == 5
                                ? Colors.white
                                : colorScheme.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 32.sp,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'أبيات شعرية',
                          style: textTheme.bodyMedium?.copyWith(
                            color: _selectedLines == 5
                                ? Colors.white.withOpacity(0.9)
                                : (isDarkMode
                                ? colorScheme.onSurface.withOpacity(0.7)
                                : Colors.black54),
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(width: 15.w),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedLines = 10;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 20.w),
                    decoration: BoxDecoration(
                      gradient: _selectedLines == 10
                          ? LinearGradient(
                        colors: [colorScheme.primary, colorScheme.primary.withOpacity(0.8)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                          : null,
                      color: _selectedLines != 10
                          ? (isDarkMode
                          ? colorScheme.background.withOpacity(0.5)
                          : colorScheme.background)
                          : null,
                      borderRadius: BorderRadius.circular(15.r),
                      border: Border.all(
                        color: _selectedLines == 10
                            ? colorScheme.primary
                            : colorScheme.outline.withOpacity(0.3),
                        width: 2.w,
                      ),
                      boxShadow: _selectedLines == 10
                          ? [
                        BoxShadow(
                          color: colorScheme.primary.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ]
                          : null,
                    ),
                    child: Column(
                      children: [
                        Text(
                          '10',
                          style: textTheme.headlineMedium?.copyWith(
                            color: _selectedLines == 10
                                ? Colors.white
                                : colorScheme.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 32.sp,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'أبيات شعرية',
                          style: textTheme.bodyMedium?.copyWith(
                            color: _selectedLines == 10
                                ? Colors.white.withOpacity(0.9)
                                : (isDarkMode
                                ? colorScheme.onSurface.withOpacity(0.7)
                                : Colors.black54),
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(GrammarMorphologyProvider provider, ColorScheme colorScheme, TextTheme textTheme) {
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
        onPressed: provider.isLoading ? null : _generatePoetry,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          padding: EdgeInsets.symmetric(vertical: 18.h),
        ),
        child: provider.isLoading
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
              'جاري إنتاج الشعر...',
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
              Icons.auto_stories_rounded,
              color: Colors.white,
              size: 24.r,
            ),
            SizedBox(width: 12.w),
            Text(
              'إنتاج الشعر',
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

  Widget _buildResultsSection(
      GrammarMorphologyProvider provider,
      ColorScheme colorScheme,
      TextTheme textTheme,
      bool isDarkMode,
      ) {
    if (provider.generatedPoetry.isEmpty && !provider.isLoading) {
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
                    'الشعر المولد:',
                    style: textTheme.titleLarge?.copyWith(
                      color: colorScheme.secondary,
                      fontWeight: FontWeight.bold,
                      fontSize: 18.sp,
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Icon(
                    Icons.star_rounded,
                    color: colorScheme.secondary,
                    size: 24.r,
                  ),
                ],
              ),
              SizedBox(height: 15.h),
              if (provider.generatedPoetry.isNotEmpty)
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(20.w),
                  decoration: BoxDecoration(
                    color: isDarkMode
                        ? colorScheme.background.withOpacity(0.5)
                        : Colors.white.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(15.r),
                    border: Border.all(
                      color: colorScheme.secondary.withOpacity(0.2),
                      width: 1.w,
                    ),
                  ),
                  child: SelectableText(
                    provider.generatedPoetry,
                    style: textTheme.bodyLarge?.copyWith(
                      color: isDarkMode ? colorScheme.onSurface : colorScheme.onBackground,
                      fontSize: 18.sp,
                      height: 1.8,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),

              SizedBox(height: 15.h),

              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildActionIcon(
                    icon: Icons.copy,
                    label: 'نسخ',
                    onTap: () {
                      _showSnackBar('تم نسخ الشعر', Colors.green);
                    },
                    colorScheme: colorScheme,
                    textTheme: textTheme,
                  ),
                  _buildActionIcon(
                    icon: Icons.share,
                    label: 'مشاركة',
                    onTap: () {
                      _showSnackBar('مشاركة الشعر', Colors.blue);
                    },
                    colorScheme: colorScheme,
                    textTheme: textTheme,
                  ),
                  _buildActionIcon(
                    icon: Icons.refresh,
                    label: 'إعادة توليد',
                    onTap: _generatePoetry,
                    colorScheme: colorScheme,
                    textTheme: textTheme,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionIcon({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required ColorScheme colorScheme,
    required TextTheme textTheme,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 16.w),
        decoration: BoxDecoration(
          color: colorScheme.secondary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: colorScheme.secondary.withOpacity(0.3),
            width: 1.w,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: colorScheme.secondary,
              size: 20.r,
            ),
            SizedBox(height: 4.h),
            Text(
              label,
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.secondary,
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
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
              Icons.auto_stories_outlined,
              size: 60.r,
              color: colorScheme.primary.withOpacity(0.7),
            ),
          ),
          SizedBox(height: 20.h),
          Text(
            'الشعر المولد سيظهر هنا',
            style: textTheme.bodyLarge?.copyWith(
              color: isDarkMode ? colorScheme.onSurface.withOpacity(0.54) : Colors.black54,
              fontSize: 16.sp,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8.h),
          Text(
            'أدخل موضوعاً واختر البحر واضغط على "إنتاج الشعر" للبدء',
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