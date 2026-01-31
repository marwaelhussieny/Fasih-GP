// lib/features/home/presentation/widgets/state_widgets.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:math' as math;

class LoadingState extends StatefulWidget {
  final bool isDarkMode;

  const LoadingState({Key? key, required this.isDarkMode}) : super(key: key);

  @override
  State<LoadingState> createState() => _LoadingStateState();
}

class _LoadingStateState extends State<LoadingState>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _pulseController;
  late AnimationController _floatingController;

  late Animation<double> _rotationAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _floatingAnimation;

  @override
  void initState() {
    super.initState();

    _rotationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _floatingController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    )..repeat();

    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.linear,
    ));

    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _floatingAnimation = Tween<double>(
      begin: -10,
      end: 10,
    ).animate(CurvedAnimation(
      parent: _floatingController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _pulseController.dispose();
    _floatingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: AnimatedBuilder(
        animation: Listenable.merge([
          _rotationAnimation,
          _pulseAnimation,
          _floatingAnimation,
        ]),
        builder: (context, child) {
          final colorScheme = Theme.of(context).colorScheme;

          final primary = colorScheme.primary ?? Colors.blue;
          final tertiary = colorScheme.tertiary ?? Colors.green;
          final onPrimary = colorScheme.onPrimary ?? Colors.white;
          final onBackground = colorScheme.onBackground ?? Colors.black;

          return Transform.translate(
            offset: Offset(0, _floatingAnimation.value),
            child: Transform.scale(
              scale: _pulseAnimation.value,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Transform.rotate(
                        angle: _rotationAnimation.value,
                        child: Container(
                          width: 140.r,
                          height: 140.r,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: primary.withOpacity(0.3),
                              width: 3,
                            ),
                          ),
                        ),
                      ),

                      // Inner pulsing circle
                      Container(
                        width: 120.r,
                        height: 120.r,
                        decoration: BoxDecoration(
                          gradient: RadialGradient(
                            colors: [
                              primary,
                              tertiary,
                              primary.withOpacity(0.7),
                            ],
                            stops: const [0.0, 0.7, 1.0],
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: primary.withOpacity(0.4),
                              blurRadius: 30,
                              offset: const Offset(0, 15),
                              spreadRadius: 0,
                            ),
                            BoxShadow(
                              color: primary.withOpacity(0.2),
                              blurRadius: 60,
                              offset: const Offset(0, 30),
                              spreadRadius: 10,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Transform.rotate(
                            angle: -_rotationAnimation.value * 0.5,
                            child: Icon(
                              Icons.school_rounded,
                              color: onPrimary,
                              size: 48.r,
                            ),
                          ),
                        ),
                      ),

                      // Orbiting particles
                      ...List.generate(6, (index) {
                        final angle = (index * math.pi * 2 / 6) + _rotationAnimation.value;
                        final radius = 80.r;
                        final x = math.cos(angle) * radius;
                        final y = math.sin(angle) * radius;

                        return Transform.translate(
                          offset: Offset(x, y),
                          child: Container(
                            width: 8.r,
                            height: 8.r,
                            decoration: BoxDecoration(
                              gradient: RadialGradient(
                                colors: [
                                  tertiary,
                                  tertiary.withOpacity(0.5),
                                ],
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: tertiary.withOpacity(0.6),
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ],
                  ),

                  SizedBox(height: 50.h),

                  // Enhanced loading text with shimmer effect
                  ShimmerText(
                    text: 'جاري تحميل مسار التعلم...',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: onBackground,
                      fontWeight: FontWeight.w600,
                      shadows: [
                        Shadow(
                          offset: const Offset(0, 2),
                          blurRadius: 4,
                          color: primary.withOpacity(0.5),
                        ),
                      ],
                    ) ??
                        const TextStyle(),
                    shimmerColor: primary,
                    animationController: _floatingController,
                  ),

                  SizedBox(height: 20.h),

                  // Progress dots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(3, (index) {
                      final delay = index * 0.3;
                      final dotAnimation = (_floatingController.value + delay) % 1.0;
                      final rawOpacity = 0.3 + 0.7 * math.sin(dotAnimation * math.pi * 2);
                      final opacity = rawOpacity.clamp(0.0, 1.0);

                      return Container(
                        margin: EdgeInsets.symmetric(horizontal: 4.w),
                        width: 8.r,
                        height: 8.r,
                        decoration: BoxDecoration(
                          color: primary.withOpacity(opacity),
                          shape: BoxShape.circle,
                        ),
                      );
                    }),
                  ),

                ],
              ),
            ),
          );
        },
      ),
    );

  }
}

class ErrorState extends StatefulWidget {
  final bool isDarkMode;
  final String? error;
  final VoidCallback onRetry;

  const ErrorState({
    Key? key,
    required this.isDarkMode,
    this.error,
    required this.onRetry,
  }) : super(key: key);

  @override
  State<ErrorState> createState() => _ErrorStateState();
}

class _ErrorStateState extends State<ErrorState>
    with SingleTickerProviderStateMixin {
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _shakeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _shakeController,
      curve: Curves.elasticOut,
    ));

    // Start shake animation
    _shakeController.forward();
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: AnimatedBuilder(
        animation: _shakeAnimation,
        builder: (context, child) {
          final shakeOffset = math.sin(_shakeAnimation.value * math.pi * 8) *
              (1 - _shakeAnimation.value) * 10;

          return Transform.translate(
            offset: Offset(shakeOffset, 0),
            child: Padding(
              padding: EdgeInsets.all(32.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Enhanced error icon with animation
                  Container(
                    padding: EdgeInsets.all(40.r),
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        colors: [
                          colorScheme.errorContainer,
                          colorScheme.errorContainer.withOpacity(0.7),
                          colorScheme.errorContainer.withOpacity(0.3),
                        ],
                        stops: const [0.3, 0.7, 1.0],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: colorScheme.error.withOpacity(0.3),
                          spreadRadius: 0,
                          blurRadius: 30,
                          offset: const Offset(0, 15),
                        ),
                        BoxShadow(
                          color: colorScheme.error.withOpacity(0.1),
                          spreadRadius: 10,
                          blurRadius: 60,
                          offset: const Offset(0, 30),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.error_outline_rounded,
                      size: 90.r,
                      color: colorScheme.error,
                    ),
                  ),

                  SizedBox(height: 40.h),

                  // Error title
                  Text(
                    'خطأ في تحميل الدروس',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: colorScheme.onBackground,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          offset: const Offset(0, 2),
                          blurRadius: 4,
                          color: colorScheme.error.withOpacity(0.3),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),

                  SizedBox(height: 16.h),

                  // Error message
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                    decoration: BoxDecoration(
                      color: colorScheme.errorContainer.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: colorScheme.error.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      widget.error ?? 'حدث خطأ غير متوقع',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onBackground.withOpacity(0.8),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  SizedBox(height: 40.h),

                  // Enhanced retry button
                  _buildEnhancedRetryButton(colorScheme),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEnhancedRetryButton(ColorScheme colorScheme) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primary,
            colorScheme.tertiary,
          ],
        ),
        borderRadius: BorderRadius.circular(30.r),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: () {
          _shakeController.reset();
          widget.onRetry();
        },
        icon: Icon(
            Icons.refresh_rounded,
            color: colorScheme.onPrimary,
            size: 28.r
        ),
        label: Text(
          'إعادة المحاولة',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: colorScheme.onPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 20.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.r),
          ),
        ),
      ),
    );
  }
}

class EmptyState extends StatefulWidget {
  final bool isDarkMode;

  const EmptyState({Key? key, required this.isDarkMode}) : super(key: key);

  @override
  State<EmptyState> createState() => _EmptyStateState();
}

class _EmptyStateState extends State<EmptyState>
    with SingleTickerProviderStateMixin {
  late AnimationController _floatingController;
  late Animation<double> _floatingAnimation;

  @override
  void initState() {
    super.initState();
    _floatingController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    )..repeat();

    _floatingAnimation = Tween<double>(
      begin: -15,
      end: 15,
    ).animate(CurvedAnimation(
      parent: _floatingController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _floatingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: AnimatedBuilder(
        animation: _floatingAnimation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _floatingAnimation.value),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Enhanced empty state icon
                Container(
                  padding: EdgeInsets.all(50.r),
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      colors: [
                        colorScheme.surface,
                        colorScheme.surface.withOpacity(0.8),
                        colorScheme.surface.withOpacity(0.5),
                      ],
                      stops: const [0.3, 0.7, 1.0],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.primary.withOpacity(0.2),
                        spreadRadius: 0,
                        blurRadius: 40,
                        offset: const Offset(0, 20),
                      ),
                      BoxShadow(
                        color: colorScheme.primary.withOpacity(0.1),
                        spreadRadius: 10,
                        blurRadius: 80,
                        offset: const Offset(0, 40),
                      ),
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(
                        Icons.school_rounded,
                        size: 120.r,
                        color: colorScheme.primary,
                      ),
                      // Floating particles around the icon
                      ...List.generate(6, (index) {
                        final angle = (index * math.pi * 2 / 6) +
                            (_floatingController.value * math.pi * 2);
                        final radius = 70.r;
                        final x = math.cos(angle) * radius;
                        final y = math.sin(angle) * radius;

                        return Transform.translate(
                          offset: Offset(x, y),
                          child: Container(
                            width: 6.r,
                            height: 6.r,
                            decoration: BoxDecoration(
                              color: colorScheme.tertiary.withOpacity(0.6),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: colorScheme.tertiary.withOpacity(0.4),
                                  blurRadius: 8,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),

                SizedBox(height: 50.h),

                // Title with enhanced styling
                Text(
                  'لا توجد دروس متاحة',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: colorScheme.onBackground,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        offset: const Offset(0, 2),
                        blurRadius: 4,
                        color: colorScheme.primary.withOpacity(0.3),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 20.h),

                // Subtitle with container
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                      color: colorScheme.primary.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    'سيتم إضافة دروس جديدة قريباً',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onBackground.withOpacity(0.8),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// Custom shimmer text widget
class ShimmerText extends StatelessWidget {
  final String text;
  final TextStyle style;
  final Color shimmerColor;
  final AnimationController animationController;

  const ShimmerText({
    Key? key,
    required this.text,
    required this.style,
    required this.shimmerColor,
    required this.animationController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animationController,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                style.color ?? Colors.black,
                shimmerColor,
                style.color ?? Colors.black,
              ],
              stops: [
                (animationController.value - 0.3).clamp(0.0, 1.0),
                animationController.value,
                (animationController.value + 0.3).clamp(0.0, 1.0),
              ],
            ).createShader(bounds);
          },
          child: Text(
            text,
            style: style,
          ),
        );
      },
    );
  }
}