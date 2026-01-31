// lib/features/grammar/presentation/screens/poetry_meter_screen.dart - COMPLETE BACKEND INTEGRATION

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:grad_project/features/grammar/presentation/providers/grammar_morphology_provider.dart';

class PoetryMeterScreen extends StatefulWidget {
  const PoetryMeterScreen({Key? key}) : super(key: key);

  @override
  State<PoetryMeterScreen> createState() => _PoetryMeterScreenState();
}

class _PoetryMeterScreenState extends State<PoetryMeterScreen>
    with TickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  late AnimationController _animationController;
  late AnimationController _resultAnimationController;

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

  Future<void> _analyzePoetryMeter() async {
    if (_textController.text.trim().isEmpty) {
      _showSnackBar('الرجاء إدخال بيت شعري لتحليل البحر.', Colors.orange);
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

    // Analyze poetry meter using the backend
    await provider.analyzePoetryMeter(_textController.text.trim());

    if (provider.error == null) {
      _resultAnimationController.forward(from: 0.0);
      _showSnackBar(provider.getSuccessMessage('meter'), Colors.green);
    } else {
      _showSnackBar(provider.getErrorMessage('meter', provider.error!), Colors.red);
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
                          'بحور الشعر',
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
              Icons.library_music_rounded,
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
                  'كاشف البحور بـ E3rbly',
                  style: textTheme.titleMedium?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 16.sp,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'أدخل بيت شعري لتحديد البحر والوزن',
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
            'أدخل البيت الشعري:',
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
              hintText: 'مثال: نا البحرُ فى أحشائِهِ الدرُّ كَامِنٌ \n فَهَلْ سَأَلُـوا الغَـوَّاصَ عَـنْ صَدَفَاتـى؟',
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
        onPressed: provider.isLoading ? null : _analyzePoetryMeter,
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
              'جاري تحليل البحر...',
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
              Icons.library_music_rounded,
              color: Colors.white,
              size: 24.r,
            ),
            SizedBox(width: 12.w),
            Text(
              'تحليل البحر',
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
    if (provider.meterEntity == null && !provider.isLoading) {
      return _buildEmptyState(colorScheme, textTheme, isDarkMode);
    }

    if (provider.meterEntity != null) {
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
                    ? [const Color(0xFF3498DB).withOpacity(0.2), const Color(0xFF3498DB).withOpacity(0.1)]
                    : [const Color(0xFF3498DB).withOpacity(0.1), const Color(0xFF3498DB).withOpacity(0.05)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(
                color: const Color(0xFF3498DB).withOpacity(0.3),
                width: 1.5.w,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.check_circle_outline,
                  color: const Color(0xFF3498DB),
                  size: 48.r,
                ),
                SizedBox(height: 15.h),
                Text(
                  provider.meterEntity!.detectedMeter,
                  style: textTheme.headlineMedium?.copyWith(
                    color: const Color(0xFF3498DB),
                    fontWeight: FontWeight.bold,
                    fontSize: 24.sp,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 10.h),
                Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: isDarkMode
                        ? colorScheme.background.withOpacity(0.5)
                        : Colors.white.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: const Color(0xFF3498DB).withOpacity(0.2),
                      width: 1.w,
                    ),
                  ),
                  child: Column(
                    children: [
                      if (provider.meterEntity!.pattern.isNotEmpty) ...[
                        Text(
                          'النمط: ${provider.meterEntity!.pattern}',
                          style: textTheme.bodyMedium?.copyWith(
                            color: isDarkMode ? colorScheme.onSurface : colorScheme.onBackground,
                            fontSize: 14.sp,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return const SizedBox.shrink();
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
              Icons.library_music_outlined,
              size: 60.r,
              color: colorScheme.primary.withOpacity(0.7),
            ),
          ),
          SizedBox(height: 20.h),
          Text(
            'نتائج تحليل البحر ستظهر هنا',
            style: textTheme.bodyLarge?.copyWith(
              color: isDarkMode ? colorScheme.onSurface.withOpacity(0.54) : Colors.black54,
              fontSize: 16.sp,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8.h),
          Text(
            'أدخل بيت شعري واضغط على "تحليل البحر" للبدء',
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