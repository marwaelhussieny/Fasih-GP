// lib/features/grammar/presentation/screens/grammar_parsing_screen.dart - REFACTORED

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:grad_project/features/grammar/presentation/providers/grammar_morphology_provider.dart';
import 'package:grad_project/features/grammar/domain/entities/grammar_morphology_entity.dart';

class GrammarParsingScreen extends StatefulWidget {
  const GrammarParsingScreen({Key? key}) : super(key: key);

  @override
  State<GrammarParsingScreen> createState() => _GrammarParsingScreenState();
}

class _GrammarParsingScreenState extends State<GrammarParsingScreen>
    with TickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  late AnimationController _resultAnimationController;

  @override
  void initState() {
    super.initState();
    _resultAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<GrammarMorphologyProvider>();
      provider.checkServiceStatus();
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _resultAnimationController.dispose();
    super.dispose();
  }

  Future<void> _performParsing() async {
    if (_textController.text.trim().isEmpty) {
      _showSnackBar('الرجاء إدخال نص للإعراب.', Colors.orange);
      return;
    }

    final provider = context.read<GrammarMorphologyProvider>();

    if (!provider.isServiceOnline) {
      await provider.checkServiceStatus();
      if (!provider.isServiceOnline) {
        _showSnackBar('خدمة E3rbly غير متوفرة حالياً. يرجى المحاولة لاحقاً.', Colors.red);
        return;
      }
    }

    await provider.performParsing(_textController.text.trim());

    if (provider.error == null) {
      _resultAnimationController.forward(from: 0.0);
      _showSnackBar(provider.getSuccessMessage('parsing'), Colors.green);
    } else {
      _showSnackBar(provider.getErrorMessage('parsing', provider.error!), Colors.red);
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
          'الإعراب بـ E3rbly',
          style: textTheme.headlineSmall?.copyWith(
            color: theme.appBarTheme.titleTextStyle?.color,
            fontSize: 24.sp,
          ),
        ),
        centerTitle: true,
        actions: [
          Consumer<GrammarMorphologyProvider>(
            builder: (context, provider, child) {
              return Container(
                margin: EdgeInsets.only(right: 16.w),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8.w,
                      height: 8.h,
                      decoration: BoxDecoration(
                        color: provider.isServiceOnline ? Colors.green : Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      provider.isServiceOnline ? 'E3rbly' : 'غير متصل',
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: provider.isServiceOnline ? Colors.green : Colors.red,
                        fontFamily: 'Tajawal',
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<GrammarMorphologyProvider>(
        builder: (context, provider, child) {
          return SingleChildScrollView(
            padding: EdgeInsets.all(20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeaderCard(colorScheme, textTheme, isDarkMode, provider),
                SizedBox(height: 20.h),
                _buildInputSection(colorScheme, textTheme, isDarkMode),
                SizedBox(height: 20.h),
                _buildActionButton(provider, colorScheme, textTheme),
                SizedBox(height: 30.h),
                _buildResultsSection(provider, colorScheme, textTheme, isDarkMode),
              ],
            ),
          );
        },
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
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Icon(
                  Icons.auto_awesome,
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
                      'الإعراب بـ E3rbly',
                      style: textTheme.titleMedium?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 16.sp,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'أدخل جملة لتحليلها نحوياً',
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
          SizedBox(height: 12.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 12.w),
            decoration: BoxDecoration(
              color: provider.isServiceOnline
                  ? Colors.green.withOpacity(0.1)
                  : Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(
                color: provider.isServiceOnline ? Colors.green : Colors.red,
                width: 1.w,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  provider.isServiceOnline ? Icons.cloud_done : Icons.cloud_off,
                  color: provider.isServiceOnline ? Colors.green : Colors.red,
                  size: 16.r,
                ),
                SizedBox(width: 8.w),
                Text(
                  provider.isServiceOnline
                      ? 'خدمة E3rbly متصلة وجاهزة للاستخدام'
                      : 'خدمة E3rbly غير متصلة',
                  style: TextStyle(
                    color: provider.isServiceOnline ? Colors.green : Colors.red,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
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
            'أدخل الجملة للإعراب:',
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
            maxLines: 4,
            style: textTheme.bodyMedium?.copyWith(
              color: isDarkMode ? colorScheme.onSurface : colorScheme.onBackground,
              fontSize: 16.sp,
              height: 1.5,
            ),
            decoration: InputDecoration(
              hintText: 'مثال: الطالب المجتهد يذهب إلى المدرسة كل يوم',
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
        onPressed: provider.isLoading ? null : _performParsing,
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
              'جاري الإعراب بـ E3rbly...',
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
              Icons.auto_fix_high_rounded,
              color: Colors.white,
              size: 24.r,
            ),
            SizedBox(width: 12.w),
            Text(
              'إعراب الجملة',
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
    if (provider.parsingResults.isEmpty && !provider.isLoading) {
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
                    'نتائج الإعراب بـ E3rbly:',
                    style: textTheme.titleLarge?.copyWith(
                      color: colorScheme.secondary,
                      fontWeight: FontWeight.bold,
                      fontSize: 18.sp,
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Icon(
                    Icons.check_circle_outline,
                    color: colorScheme.secondary,
                    size: 24.r,
                  ),
                ],
              ),
              SizedBox(height: 15.h),
              ...provider.parsingResults.asMap().entries.map((entry) {
                final index = entry.key;
                final result = entry.value;
                return TweenAnimationBuilder<double>(
                  duration: Duration(milliseconds: 200 + (index * 100)),
                  tween: Tween(begin: 0.0, end: 1.0),
                  builder: (context, animation, child) {
                    return Transform.translate(
                      offset: Offset(0, 20 * (1 - animation)),
                      child: Opacity(
                        opacity: animation,
                        child: _buildParsingResultCard(result, colorScheme, textTheme, isDarkMode),
                      ),
                    );
                  },
                );
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildParsingResultCard(
      ParsingResultEntity result,
      ColorScheme colorScheme,
      TextTheme textTheme,
      bool isDarkMode,
      ) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            result.word,
            style: textTheme.titleMedium?.copyWith(
              color: colorScheme.secondary,
              fontWeight: FontWeight.bold,
              fontSize: 18.sp,
            ),
            textAlign: TextAlign.right,
          ),
          SizedBox(height: 8.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: colorScheme.secondary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Text(
              result.parsing,
              style: textTheme.bodyMedium?.copyWith(
                color: isDarkMode ? colorScheme.onSurface : colorScheme.onBackground,
                fontSize: 14.sp,
                height: 1.4,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
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
              Icons.edit_note_outlined,
              size: 60.r,
              color: colorScheme.primary.withOpacity(0.7),
            ),
          ),
          SizedBox(height: 20.h),
          Text(
            'نتائج الإعراب ستظهر هنا',
            style: textTheme.bodyLarge?.copyWith(
              color: isDarkMode ? colorScheme.onSurface.withOpacity(0.54) : Colors.black54,
              fontSize: 16.sp,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8.h),
          Text(
            'أدخل جملة واضغط على "إعراب الجملة" لبدء التحليل',
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