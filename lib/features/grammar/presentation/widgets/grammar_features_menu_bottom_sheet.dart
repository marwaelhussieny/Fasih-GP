// lib/features/grammar/presentation/screens/grammar_features_menu_bottom_sheet.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:grad_project/core/navigation/app_routes.dart';
import 'package:grad_project/features/grammar/presentation/widgets/grammar_features_menu_bottom_sheet.dart'; // This import is for the actual bottom sheet widget, not the screen itself.

// Removed direct color imports from home_screen.dart for theme consistency.
// All colors will now be derived from Theme.of(context).colorScheme.

class FeaturesMenuBottomSheet extends StatefulWidget {
  final bool isDarkMode; // This parameter is kept as it's passed from outside.

  const FeaturesMenuBottomSheet({Key? key, required this.isDarkMode}) : super(key: key);

  @override
  State<FeaturesMenuBottomSheet> createState() => _FeaturesMenuBottomSheetState();
}

class _FeaturesMenuBottomSheetState extends State<FeaturesMenuBottomSheet>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.elasticOut,
    ));

    _animationController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final TextTheme textTheme = theme.textTheme;
    final bool isDarkMode = theme.brightness == Brightness.dark; // Derive isDarkMode from theme

    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          color: colorScheme.background, // Use theme background color
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25.r),
            topRight: Radius.circular(25.r),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, -5),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Column(
          children: [
            _buildDragHandle(isDarkMode, colorScheme),
            _buildHeader(isDarkMode, colorScheme, textTheme),
            Expanded(
              child: _buildFeaturesGrid(isDarkMode, colorScheme),
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  Widget _buildDragHandle(bool isDarkMode, ColorScheme colorScheme) {
    return Container(
      margin: EdgeInsets.only(top: 12.h),
      width: 60.w,
      height: 5.h,
      decoration: BoxDecoration(
        color: isDarkMode ? colorScheme.tertiary.withOpacity(0.6) : colorScheme.primary.withOpacity(0.6), // Use theme colors
        borderRadius: BorderRadius.circular(10.r),
      ),
    );
  }

  Widget _buildHeader(bool isDarkMode, ColorScheme colorScheme, TextTheme textTheme) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        margin: EdgeInsets.all(20.w),
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDarkMode
                ? [colorScheme.primaryContainer.withOpacity(0.8), colorScheme.tertiary.withOpacity(0.1)] // Use theme colors
                : [colorScheme.primary.withOpacity(0.1), colorScheme.secondary.withOpacity(0.05)], // Use theme colors
          ),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isDarkMode ? colorScheme.tertiary.withOpacity(0.3) : colorScheme.primary.withOpacity(0.2), // Use theme colors
            width: 1.5.w,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDarkMode
                      ? [colorScheme.tertiary.withOpacity(0.3), colorScheme.tertiary.withOpacity(0.1)] // Use theme colors
                      : [colorScheme.primary.withOpacity(0.3), colorScheme.primary.withOpacity(0.1)], // Use theme colors
                ),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Icon(
                Icons.auto_awesome,
                color: isDarkMode ? colorScheme.tertiary : colorScheme.primary, // Use theme colors
                size: 28.r,
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'المميزات اللغوية',
                    style: textTheme.titleMedium?.copyWith( // Use textTheme
                      color: isDarkMode ? colorScheme.onBackground : colorScheme.primary, // Use theme colors
                      fontWeight: FontWeight.bold,
                      fontSize: 18.sp,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'اكتشف قوة اللغة العربية بالذكاء الاصطناعي',
                    style: textTheme.bodySmall?.copyWith( // Use textTheme
                      color: isDarkMode ? colorScheme.onBackground.withOpacity(0.7) : Colors.black87, // Use theme colors or fallback
                      fontSize: 12.sp,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturesGrid(bool isDarkMode, ColorScheme colorScheme) {
    final features = [
      {
        'title': 'إعراب/تصريف',
        'description': 'إعراب الجمل وتصريف الأفعال تلقائياً',
        'icon': Icons.text_format_rounded,
        'color': isDarkMode ? colorScheme.tertiary : colorScheme.primary, // Use theme colors
        'onTap': () {
          Navigator.pop(context);
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => FeaturesMenuBottomSheet(isDarkMode: isDarkMode), // Corrected: Use FeaturesMenuBottomSheet
          );
        },
      },
      {
        'title': 'إنتاج الشعر',
        'description': 'إنتاج الشعر العربي بالذكاء الاصطناعي',
        'icon': Icons.auto_stories_rounded,
        'color': isDarkMode ? colorScheme.secondary : colorScheme.secondary, // Use theme colors
        'onTap': () {
          Navigator.pop(context);
          Navigator.pushNamed(context, AppRoutes.poetryGeneration);
        },
      },
      {
        'title': 'الجمع',
        'description': 'البحث عن جمع الكلمات العربية',
        'icon': Icons.group_work_rounded,
        'color': isDarkMode ? colorScheme.onSurface : colorScheme.surfaceVariant, // Use theme colors
        'onTap': () {
          Navigator.pop(context);
          Navigator.pushNamed(context, AppRoutes.pluralFinder);
        },
      },
      {
        'title': 'التضاد',
        'description': 'البحث عن أضداد الكلمات العربية',
        'icon': Icons.compare_arrows_rounded,
        'color': isDarkMode ? colorScheme.error : colorScheme.error, // Use theme colors
        'onTap': () {
          Navigator.pop(context);
          Navigator.pushNamed(context, AppRoutes.antonymFinder);
        },
      },
      {
        'title': 'المعنى',
        'description': 'البحث عن معاني الكلمات العربية',
        'icon': Icons.psychology_rounded,
        'color': isDarkMode ? colorScheme.tertiary : colorScheme.primary, // Use theme colors
        'onTap': () {
          Navigator.pop(context);
          Navigator.pushNamed(context, AppRoutes.meaningFinder);
        },
      },
    ];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16.w,
          mainAxisSpacing: 16.h,
          childAspectRatio: 1.0,
        ),
        itemCount: features.length,
        itemBuilder: (context, index) {
          final feature = features[index];

          return TweenAnimationBuilder<double>(
            duration: Duration(milliseconds: 400 + (index * 100)),
            tween: Tween(begin: 0.0, end: 1.0),
            curve: Curves.elasticOut,
            builder: (context, animation, child) {
              return Transform.scale(
                scale: 0.8 + (animation * 0.2),
                child: Opacity(
                  opacity: animation,
                  child: _buildFeatureCard(
                    title: feature['title'] as String,
                    description: feature['description'] as String,
                    icon: feature['icon'] as IconData,
                    color: feature['color'] as Color,
                    onTap: feature['onTap'] as VoidCallback,
                    isDarkMode: isDarkMode, // Pass isDarkMode to the card builder
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildFeatureCard({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    required bool isDarkMode, // Added isDarkMode parameter
  }) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final TextTheme textTheme = theme.textTheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: isDarkMode ? colorScheme.surface.withOpacity(0.7) : Colors.white, // Use theme colors
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1.5.w,
          ),
          boxShadow: [
            BoxShadow(
              color: (isDarkMode ? Colors.black : Colors.grey).withOpacity(0.1),
              blurRadius: 15,
              offset: const Offset(0, 5),
              spreadRadius: 0,
            ),
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
              spreadRadius: -5,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                icon,
                color: color,
                size: 32.r,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              title,
              style: textTheme.titleSmall?.copyWith( // Use textTheme
                color: isDarkMode ? colorScheme.onSurface : color, // Use theme colors
                fontWeight: FontWeight.bold,
                fontSize: 14.sp,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 6.h),
            Text(
              description,
              style: textTheme.bodySmall?.copyWith( // Use textTheme
                color: isDarkMode ? colorScheme.onSurface.withOpacity(0.7) : Colors.black87, // Use theme colors or fallback
                fontSize: 10.sp,
                height: 1.3,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
