// lib/features/grammar/presentation/widgets/enhanced_features_menu_bottom_sheet.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:grad_project/core/navigation/app_routes.dart';

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

    // Add listeners to ensure animations stay within bounds
    _animationController.addListener(() {
      if (_animationController.value < 0.0 || _animationController.value > 1.0) {
        _animationController.stop();
      }
    });

    _slideController.addListener(() {
      if (_slideController.value < 0.0 || _slideController.value > 1.0) {
        _slideController.stop();
      }
    });

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

    return AnimatedBuilder(
      animation: Listenable.merge([_animationController, _slideController]),
      builder: (context, child) {
        // Ensure animation values are always valid
        final fadeValue = _fadeAnimation.value.clamp(0.0, 1.0);

        return SlideTransition(
          position: _slideAnimation,
          child: Opacity(
            opacity: fadeValue,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.85,
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 25.h),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: isDarkMode
                      ? [colorScheme.surface, colorScheme.background]
                      : [Colors.white, colorScheme.background],
                ),
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
                children: [
                  // Drag Handle
                  Container(
                    width: 60.w,
                    height: 5.h,
                    decoration: BoxDecoration(
                      color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                  SizedBox(height: 25.h),

                  // Header
                  Container(
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
                                'المميزات اللغوية',
                                style: textTheme.titleLarge?.copyWith(
                                  color: isDarkMode ? colorScheme.onBackground : colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                'اكتشف قوة اللغة العربية بالذكاء الاصطناعي',
                                style: textTheme.bodySmall?.copyWith(
                                  color: isDarkMode ? colorScheme.onBackground.withOpacity(0.7) : Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 25.h),

                  // Features Grid - Fixed with proper constraints
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        // Calculate available space for grid items
                        final availableWidth = constraints.maxWidth - 20.w; // Account for crossAxisSpacing
                        final itemWidth = (availableWidth / 2) - 10.w; // Two columns with spacing
                        final aspectRatio = itemWidth / (itemWidth * 0.9); // Slightly taller than wide

                        return GridView.count(
                          shrinkWrap: false,
                          physics: const BouncingScrollPhysics(),
                          crossAxisCount: 2,
                          mainAxisSpacing: 15.h,
                          crossAxisSpacing: 15.w,
                          childAspectRatio: aspectRatio,
                          children: [
                            _buildFeatureItem(
                              icon: Icons.spellcheck_rounded,
                              title: 'الإعراب',
                              description: 'تحليل الجمل وتحديد مواقع الكلمات',
                              gradientColors: [colorScheme.primary, colorScheme.primary.withOpacity(0.7)],
                              onTap: () {
                                Navigator.pop(context);
                                Navigator.pushNamed(context, AppRoutes.grammarParsing);
                              },
                              context: context,
                              index: 0,
                            ),
                            _buildFeatureItem(
                              icon: Icons.menu_book_rounded,
                              title: 'الصرف',
                              description: 'دراسة بنية الكلمات وتصريفها',
                              gradientColors: [colorScheme.secondary, colorScheme.secondary.withOpacity(0.7)],
                              onTap: () {
                                Navigator.pop(context);
                                Navigator.pushNamed(context, AppRoutes.morphology);
                              },
                              context: context,
                              index: 1,
                            ),
                            _buildFeatureItem(
                              icon: Icons.lightbulb_outline_rounded,
                              title: 'المعنى',
                              description: 'استكشاف معاني الكلمات والجمل',
                              gradientColors: [colorScheme.tertiary, colorScheme.tertiary.withOpacity(0.7)],
                              onTap: () {
                                Navigator.pop(context);
                                Navigator.pushNamed(context, AppRoutes.meaningFinder);
                              },
                              context: context,
                              index: 2,
                            ),
                            _buildFeatureItem(
                              icon: Icons.compare_arrows_rounded,
                              title: 'التضاد',
                              description: 'البحث عن الكلمات المتضادة',
                              gradientColors: [const Color(0xFFE74C3C), const Color(0xFFE74C3C).withOpacity(0.7)],
                              onTap: () {
                                Navigator.pop(context);
                                Navigator.pushNamed(context, AppRoutes.antonymFinder);
                              },
                              context: context,
                              index: 3,
                            ),
                            _buildFeatureItem(
                              icon: Icons.looks_two_rounded,
                              title: 'الجمع',
                              description: 'إيجاد صيغ الجمع للكلمات المفردة',
                              gradientColors: [const Color(0xFF9B59B6), const Color(0xFF9B59B6).withOpacity(0.7)],
                              onTap: () {
                                Navigator.pop(context);
                                Navigator.pushNamed(context, AppRoutes.pluralFinder);
                              },
                              context: context,
                              index: 4,
                            ),
                            _buildFeatureItem(
                              icon: Icons.auto_stories_rounded,
                              title: 'توليد الشعر',
                              description: 'إنشاء قصائد شعرية بالذكاء الاصطناعي',
                              gradientColors: [const Color(0xFFF39C12), const Color(0xFFF39C12).withOpacity(0.7)],
                              onTap: () {
                                Navigator.pop(context);
                                Navigator.pushNamed(context, AppRoutes.poetryGeneration);
                              },
                              context: context,
                              index: 5,
                            ),
                            _buildFeatureItem(
                              icon: Icons.library_music_rounded,
                              title: 'بحور الشعر',
                              description: 'تحديد البحر الشعري للقصائد',
                              gradientColors: [const Color(0xFF3498DB), const Color(0xFF3498DB).withOpacity(0.7)],
                              onTap: () {
                                Navigator.pop(context);
                                Navigator.pushNamed(context, AppRoutes.poetryMeter);
                              },
                              context: context,
                              index: 6,
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String description,
    required List<Color> gradientColors,
    required VoidCallback onTap,
    required BuildContext context,
    required int index,
  }) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final TextTheme textTheme = theme.textTheme;
    final bool isDarkMode = theme.brightness == Brightness.dark;

    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 400 + (index * 100)),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeOutBack,
      builder: (context, animation, child) {
        // Clamp animation value to ensure it's always between 0.0 and 1.0
        final clampedAnimation = animation.clamp(0.0, 1.0);

        return Transform.scale(
          scale: clampedAnimation,
          child: Opacity(
            opacity: clampedAnimation,
            child: GestureDetector(
              onTap: onTap,
              child: Container(
                padding: EdgeInsets.all(12.w), // Reduced padding
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDarkMode
                        ? [colorScheme.surface, colorScheme.surface.withOpacity(0.8)]
                        : [Colors.white, Colors.white.withOpacity(0.95)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16.r), // Slightly smaller radius
                  border: Border.all(
                    color: gradientColors[0].withOpacity(0.3),
                    width: 1.w,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: gradientColors[0].withOpacity(0.15),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min, // Important: let content determine size
                  children: [
                    // Icon container - made more compact
                    Container(
                      padding: EdgeInsets.all(10.w), // Reduced padding
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            gradientColors[0].withOpacity(0.15),
                            gradientColors[1].withOpacity(0.1),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                      child: Icon(
                        icon,
                        color: gradientColors[0],
                        size: 26.r, // Slightly smaller icon
                      ),
                    ),
                    SizedBox(height: 8.h), // Reduced spacing

                    // Title - with better constraints
                    Flexible(
                      child: Text(
                        title,
                        style: textTheme.titleSmall?.copyWith( // Changed to titleSmall
                          color: isDarkMode ? colorScheme.onSurface : gradientColors[0],
                          fontWeight: FontWeight.bold,
                          fontSize: 14.sp, // Explicit font size
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(height: 4.h), // Reduced spacing

                    // Description - with better constraints
                    Flexible(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4.w), // Reduced horizontal padding
                        child: Text(
                          description,
                          style: textTheme.bodySmall?.copyWith(
                            color: isDarkMode ? colorScheme.onSurface.withOpacity(0.7) : Colors.black54,
                            height: 1.2, // Reduced line height
                            fontSize: 11.sp, // Smaller font size
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}