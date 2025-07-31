// lib/features/grammar/presentation/widgets/features_menu_bottom_sheet.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:grad_project/core/navigation/app_routes.dart';
// Removed direct color imports

class EnhancedFeaturesMenuBottomSheet extends StatefulWidget {
  const EnhancedFeaturesMenuBottomSheet({Key? key}) : super(key: key);

  @override
  State<EnhancedFeaturesMenuBottomSheet> createState() => _EnhancedFeaturesMenuBottomSheetState();
}

class _EnhancedFeaturesMenuBottomSheetState extends State<EnhancedFeaturesMenuBottomSheet>
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

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _slideController,
        curve: Curves.easeOutCubic,
      ),
    );

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
    final bool isDarkMode = theme.brightness == Brightness.dark;

    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 25.h),
          decoration: BoxDecoration(
            color: colorScheme.background, // Use theme background color
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30.r),
              topRight: Radius.circular(30.r),
            ),
            boxShadow: [
              BoxShadow(
                color: (isDarkMode ? Colors.black : Colors.grey).withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60.w,
                height: 5.h,
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
              SizedBox(height: 25.h),
              Text(
                'اختر ميزة نحوية', // Choose a Grammar Feature
                style: textTheme.headlineSmall?.copyWith(
                  color: isDarkMode ? colorScheme.onBackground : colorScheme.primary, // Use onBackground/primary
                  fontSize: 22.sp,
                ),
              ),
              SizedBox(height: 25.h),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 3,
                mainAxisSpacing: 20.h,
                crossAxisSpacing: 20.w,
                children: [
                  _buildFeatureItem(
                    icon: Icons.spellcheck_rounded,
                    title: 'الإعراب', // Parsing
                    description: 'تحليل الجمل وتحديد مواقع الكلمات.',
                    color: colorScheme.primary, // Use theme primary color
                    onTap: () {
                      Navigator.pop(context); // Close bottom sheet
                      Navigator.pushNamed(context, AppRoutes.grammarParsing);
                    },
                    context: context,
                  ),
                  _buildFeatureItem(
                    icon: Icons.menu_book_rounded,
                    title: 'الصرف', // Morphology
                    description: 'دراسة بنية الكلمات وتصريفها.',
                    color: colorScheme.secondary, // Use theme secondary color
                    onTap: () {
                      Navigator.pop(context); // Close bottom sheet
                      Navigator.pushNamed(context, AppRoutes.morphology);
                    },
                    context: context,
                  ),
                  _buildFeatureItem(
                    icon: Icons.lightbulb_outline_rounded,
                    title: 'المعنى', // Meaning
                    description: 'استكشاف معاني الكلمات والجمل.',
                    color: colorScheme.tertiary, // Use theme tertiary color
                    onTap: () {
                      Navigator.pop(context); // Close bottom sheet
                      Navigator.pushNamed(context, AppRoutes.meaningFinder);
                    },
                    context: context,
                  ),
                  _buildFeatureItem(
                    icon: Icons.compare_arrows_rounded,
                    title: 'التضاد', // Antonym
                    description: 'البحث عن الكلمات المتضادة.',
                    color: colorScheme.error, // Use theme error color (or another distinct color)
                    onTap: () {
                      Navigator.pop(context); // Close bottom sheet
                      Navigator.pushNamed(context, AppRoutes.antonymFinder);
                    },
                    context: context,
                  ),
                  _buildFeatureItem(
                    icon: Icons.looks_two_rounded,
                    title: 'الجمع', // Plural
                    description: 'إيجاد صيغ الجمع للكلمات المفردة.',
                    color: colorScheme.primary.withOpacity(0.7), // Use primary with opacity
                    onTap: () {
                      Navigator.pop(context); // Close bottom sheet
                      Navigator.pushNamed(context, AppRoutes.pluralFinder);
                    },
                    context: context,
                  ),
                  _buildFeatureItem(
                    icon: Icons.auto_stories_rounded,
                    title: 'توليد الشعر', // Poetry Generation
                    description: 'إنشاء قصائد شعرية بناءً على المدخلات.',
                    color: colorScheme.secondary.withOpacity(0.7), // Use secondary with opacity
                    onTap: () {
                      Navigator.pop(context); // Close bottom sheet
                      Navigator.pushNamed(context, AppRoutes.poetryGeneration);
                    },
                    context: context,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required VoidCallback onTap,
    required BuildContext context,
  }) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final TextTheme textTheme = theme.textTheme;
    final bool isDarkMode = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: isDarkMode ? colorScheme.surface : Colors.white, // Use surface/white
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1.5.w,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.2),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    color.withOpacity(0.8),
                    color.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(18.r),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.4),
                    blurRadius: 10,
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
              style: textTheme.titleSmall?.copyWith( // Use titleSmall
                color: isDarkMode ? colorScheme.onSurface : colorScheme.onBackground, // Use onSurface/onBackground
                fontWeight: FontWeight.bold,
                fontSize: 15.sp,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 6.h),
            Flexible(
              child: Text(
                description,
                style: textTheme.bodySmall?.copyWith( // Use bodySmall
                  color: isDarkMode ? colorScheme.onSurface.withOpacity(0.75) : Colors.black87, // Replaced secondaryTextColor
                  fontSize: 10.sp,
                  height: 1.3,
                ),
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
