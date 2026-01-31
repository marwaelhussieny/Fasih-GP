// lib/features/home/presentation/widgets/progress_lessons_details.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:grad_project/features/home/presentation/providers/home_provider.dart';
import 'package:grad_project/features/profile/presentation/providers/user_provider.dart';
import 'dart:math' as math;

class ProgressLessonsDetails extends StatelessWidget {
  final VoidCallback onScrollUpTap;
  final VoidCallback onScrollDownTap;
  final VoidCallback onScrollToCurrentTap;
  final bool isAtStart;
  final bool isAtEnd;
  final bool isAtCurrent;
  final HomeProvider homeProvider;
  final Animation<double>? floatingAnimation; // Optional floating animation

  const ProgressLessonsDetails({
    Key? key,
    required this.onScrollUpTap,
    required this.onScrollDownTap,
    required this.onScrollToCurrentTap,
    required this.isAtStart,
    required this.isAtEnd,
    required this.isAtCurrent,
    required this.homeProvider,
    this.floatingAnimation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;
    final userProvider = context.watch<UserProvider>();

    return SizedBox(
      height: 400.h,
      child: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: AnimatedBuilder(
                animation: floatingAnimation ?? const AlwaysStoppedAnimation(0.0),
                builder: (context, child) {
                  final floatOffset = floatingAnimation != null
                      ? 5 * math.sin(floatingAnimation!.value * math.pi * 2)
                      : 0.0;

                  return Transform.translate(
                    offset: Offset(0, floatOffset),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,  // Important to avoid infinite height
                        children: [
                          _buildProgressHeader(context, colorScheme, userProvider, isDarkMode),
                          SizedBox(height: 16.h),
                          _buildNavigationControls(context, colorScheme, isDarkMode),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressHeader(BuildContext context, ColorScheme colorScheme, UserProvider userProvider, bool isDarkMode) {
    return Container(
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.surface.withOpacity(0.95),
            colorScheme.background.withOpacity(0.9),
          ],
        ),
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(
          color: colorScheme.primary.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withOpacity(0.15),
            blurRadius: 25,
            offset: const Offset(0, 10),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(isDarkMode ? 0.3 : 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Row(
        children: [
          // Enhanced User Avatar with animation
          _buildAnimatedAvatar(colorScheme, isDarkMode),
          SizedBox(width: 16.w),

          // Enhanced User Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userProvider.user?.name ?? 'المتعلم',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 6.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        colorScheme.primary.withOpacity(0.1),
                        colorScheme.tertiary.withOpacity(0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: colorScheme.primary.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    'المستوى ${homeProvider.getUserRank()}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Enhanced Points Display
          _buildPointsDisplay(context, colorScheme, isDarkMode),
        ],
      ),
    );
  }

  Widget _buildAnimatedAvatar(ColorScheme colorScheme, bool isDarkMode) {
    return AnimatedBuilder(
      animation: floatingAnimation ?? const AlwaysStoppedAnimation(0.0),
      builder: (context, child) {
        final pulseScale = floatingAnimation != null
            ? 1.0 + 0.05 * math.sin(floatingAnimation!.value * math.pi * 3)
            : 1.0;

        return Transform.scale(
          scale: pulseScale,
          child: Container(
            padding: EdgeInsets.all(14.r),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  colorScheme.primary,
                  colorScheme.tertiary,
                ],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: colorScheme.primary.withOpacity(0.4),
                  blurRadius: 15,
                  offset: const Offset(0, 6),
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Icon(
              Icons.person_rounded,
              color: colorScheme.onPrimary,
              size: 26.r,
            ),
          ),
        );
      },
    );
  }

  Widget _buildPointsDisplay(BuildContext context, ColorScheme colorScheme, bool isDarkMode) {
    return AnimatedBuilder(
      animation: floatingAnimation ?? const AlwaysStoppedAnimation(0.0),
      builder: (context, child) {
        final shimmerOffset = floatingAnimation != null
            ? floatingAnimation!.value
            : 0.0;

        return Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDarkMode
                  ? [
                const Color(0xFF4CAF50),
                const Color(0xFF66BB6A),
              ]
                  : [
                const Color(0xFFFF9800),
                const Color(0xFFFFB74D),
              ],
              stops: [0.0 + shimmerOffset * 0.1, 1.0 + shimmerOffset * 0.1],
            ),
            borderRadius: BorderRadius.circular(20.r),
            boxShadow: [
              BoxShadow(
                color: (isDarkMode ? const Color(0xFF4CAF50) : const Color(0xFFFF9800))
                    .withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.star_rounded,
                color: Colors.white,
                size: 18.r,
              ),
              SizedBox(width: 6.w),
              Text(
                '${homeProvider.totalXP}',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNavigationControls(BuildContext context, ColorScheme colorScheme, bool isDarkMode) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.surface.withOpacity(0.9),
            colorScheme.background.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: colorScheme.primary.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Scroll Up Button
          _buildEnhancedNavButton(
            context,
            icon: Icons.keyboard_arrow_up_rounded,
            onTap: isAtStart ? null : onScrollUpTap,
            isDisabled: isAtStart,
            colorScheme: colorScheme,
            isDarkMode: isDarkMode,
            label: 'للأعلى',
          ),

          // Current Position Button
          _buildEnhancedNavButton(
            context,
            icon: Icons.my_location_rounded,
            onTap: isAtCurrent ? null : onScrollToCurrentTap,
            isDisabled: isAtCurrent,
            colorScheme: colorScheme,
            isDarkMode: isDarkMode,
            isSpecial: true,
            label: 'الحالي',
          ),

          // Scroll Down Button
          _buildEnhancedNavButton(
            context,
            icon: Icons.keyboard_arrow_down_rounded,
            onTap: isAtEnd ? null : onScrollDownTap,
            isDisabled: isAtEnd,
            colorScheme: colorScheme,
            isDarkMode: isDarkMode,
            label: 'للأسفل',
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedNavButton(
      BuildContext context, {
        required IconData icon,
        required VoidCallback? onTap,
        required bool isDisabled,
        required ColorScheme colorScheme,
        required bool isDarkMode,
        bool isSpecial = false,
        required String label,
      }) {
    return AnimatedBuilder(
      animation: floatingAnimation ?? const AlwaysStoppedAnimation(0.0),
      builder: (context, child) {
        final rotationAngle = floatingAnimation != null && !isDisabled
            ? math.sin(floatingAnimation!.value * math.pi * 4) * 0.1
            : 0.0;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: onTap,
              child: Transform.rotate(
                angle: rotationAngle,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  padding: EdgeInsets.all(14.r),
                  decoration: BoxDecoration(
                    gradient: isDisabled
                        ? null
                        : LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: isSpecial
                          ? [
                        const Color(0xFF4CAF50),
                        const Color(0xFF66BB6A),
                      ]
                          : [
                        colorScheme.primary,
                        colorScheme.tertiary,
                      ],
                    ),
                    color: isDisabled
                        ? colorScheme.outline.withOpacity(0.3)
                        : null,
                    shape: BoxShape.circle,
                    boxShadow: isDisabled
                        ? null
                        : [
                      BoxShadow(
                        color: (isSpecial
                            ? const Color(0xFF4CAF50)
                            : colorScheme.primary)
                            .withOpacity(0.4),
                        blurRadius: 15,
                        offset: const Offset(0, 6),
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: Icon(
                    icon,
                    color: isDisabled
                        ? colorScheme.outline
                        : Colors.white,
                    size: 26.r,
                  ),
                ),
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: isDisabled
                    ? colorScheme.outline
                    : colorScheme.onSurface.withOpacity(0.8),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        );
      },
    );
  }
}