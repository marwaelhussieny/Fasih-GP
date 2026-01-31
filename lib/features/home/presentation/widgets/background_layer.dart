// lib/features/home/presentation/widgets/background_layer.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:grad_project/features/home/presentation/painters/app_painters.dart';
import 'dart:math' as math;

class BackgroundLayer extends StatelessWidget {
  final bool isDarkMode;
  final Animation<double> sunsetAnimation;
  final Animation<double> starAnimation;
  final Animation<double> cloudAnimation;
  final AnimationController starController;
  final Animation<double> floatingAnimation;
  final ValueChanged<bool> onDayNightToggle;

  const BackgroundLayer({
    Key? key,
    required this.isDarkMode,
    required this.sunsetAnimation,
    required this.starAnimation,
    required this.cloudAnimation,
    required this.starController,
    required this.floatingAnimation,
    required this.onDayNightToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Stack(
      children: [
        // Enhanced desert dunes background with smoother gradients
        _buildDesertDunes(colorScheme),

        // Enhanced floating particles with various sizes and speeds
        _buildEnhancedFloatingParticles(colorScheme),

        // Enhanced moving elements
        if (!isDarkMode) ...[
          _buildEnhancedClouds(colorScheme),
          _buildFloatingSandParticles(colorScheme),
        ] else ...[
          _buildStarsAndMoon(colorScheme),
          _buildAurora(colorScheme),
        ],

        // Enhanced twinkling stars for night mode
        if (isDarkMode) _buildEnhancedTwinklingStars(colorScheme),

        // Animated day/night toggle button
        Positioned(
          top: 60.h,
          right: 20.w,
          child: _buildEnhancedDayNightToggle(colorScheme),
        ),

        // Enhanced sand footer with wave animations
        Align(
          alignment: Alignment.bottomCenter,
          child: SizedBox(
            height: 200.h,
            width: double.infinity,
            child: _buildEnhancedSandFooter(colorScheme),
          ),
        ),
      ],
    );
  }

  Widget _buildDesertDunes(ColorScheme colorScheme) {
    return Positioned.fill(
      child: AnimatedBuilder(
        animation: sunsetAnimation,
        builder: (context, child) {
          return CustomPaint(
            painter: EnhancedDesertDunesPainter(
              isDarkMode: isDarkMode,
              animationValue: sunsetAnimation.value,
              primaryColor: colorScheme.primary,
              surfaceColor: colorScheme.surface,
              backgroundColor: colorScheme.background,
            ),
          );
        },
      ),
    );
  }

  Widget _buildEnhancedFloatingParticles(ColorScheme colorScheme) {
    return Stack(
      children: List.generate(25, (index) {
        return AnimatedBuilder(
          animation: Listenable.merge([starAnimation, floatingAnimation]),
          builder: (context, child) {
            final baseOffset = (index * 0.15) % 1.0;
            final animValue = (starAnimation.value + baseOffset) % 1.0;
            final floatValue = (floatingAnimation.value + baseOffset * 0.5) % 1.0;

            final screenWidth = MediaQuery.of(context).size.width;
            final screenHeight = MediaQuery.of(context).size.height;

            // Create varied movement patterns
            final x = 30.w + (screenWidth - 60.w) *
                ((index / 25 + animValue * 0.08 + math.sin(floatValue * math.pi * 2) * 0.05) % 1.0);
            final y = 100.h + (screenHeight * 0.7) *
                (animValue + math.sin(animValue * math.pi * 3 + index) * 0.15 +
                    math.cos(floatValue * math.pi * 2.5) * 0.08);

            // Varied particle sizes and opacity
            final size = (1.5 + (index % 5) + math.sin(animValue * math.pi * 4) * 0.5).r;
            final opacity = 0.4 + 0.6 * ((math.sin(animValue * math.pi * 2) + 1) / 2);

            return Positioned(
              left: x,
              top: y,
              child: Transform.scale(
                scale: 0.7 + 0.3 * math.sin(floatValue * math.pi * 3),
                child: Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      colors: [
                        (isDarkMode ? colorScheme.tertiary : colorScheme.primary)
                            .withOpacity(opacity),
                        (isDarkMode ? colorScheme.tertiary : colorScheme.primary)
                            .withOpacity(opacity * 0.3),
                      ],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: (isDarkMode ? colorScheme.tertiary : colorScheme.primary)
                            .withOpacity(0.6),
                        blurRadius: isDarkMode ? 12 : 6,
                        spreadRadius: isDarkMode ? 3 : 1.5,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }

  Widget _buildEnhancedClouds(ColorScheme colorScheme) {
    return Stack(
      children: [
        // Large background cloud
        AnimatedBuilder(
          animation: Listenable.merge([cloudAnimation, floatingAnimation]),
          builder: (context, child) {
            final screenWidth = MediaQuery.of(context).size.width;
            return Positioned(
              top: 40.h + (30 * math.sin(cloudAnimation.value * math.pi * 2)) +
                  (10 * math.cos(floatingAnimation.value * math.pi * 3)),
              right: -120.w + (screenWidth * cloudAnimation.value * 0.4),
              child: Transform.scale(
                scale: 0.9 + 0.1 * math.sin(floatingAnimation.value * math.pi * 2),
                child: _buildFluffyCloud(
                  colorScheme.surface.withOpacity(0.8),
                  140.w,
                  70.h,
                  colorScheme,
                ),
              ),
            );
          },
        ),
        // Medium cloud
        AnimatedBuilder(
          animation: Listenable.merge([cloudAnimation, floatingAnimation]),
          builder: (context, child) {
            final screenWidth = MediaQuery.of(context).size.width;
            return Positioned(
              top: 120.h + (25 * math.cos(cloudAnimation.value * math.pi * 1.8)) +
                  (15 * math.sin(floatingAnimation.value * math.pi * 2.5)),
              left: -80.w + (screenWidth * cloudAnimation.value * 0.3),
              child: Transform.scale(
                scale: 0.7 + 0.15 * math.cos(floatingAnimation.value * math.pi * 1.8),
                child: _buildFluffyCloud(
                  colorScheme.surface.withOpacity(0.6),
                  110.w,
                  55.h,
                  colorScheme,
                ),
              ),
            );
          },
        ),
        // Small foreground cloud
        AnimatedBuilder(
          animation: Listenable.merge([cloudAnimation, floatingAnimation]),
          builder: (context, child) {
            final screenWidth = MediaQuery.of(context).size.width;
            return Positioned(
              top: 180.h + (20 * math.sin(cloudAnimation.value * math.pi * 2.8)) +
                  (8 * math.cos(floatingAnimation.value * math.pi * 4)),
              right: -40.w + (screenWidth * cloudAnimation.value * 0.5),
              child: Transform.scale(
                scale: 0.5 + 0.1 * math.sin(floatingAnimation.value * math.pi * 3),
                child: _buildFluffyCloud(
                  colorScheme.primary.withOpacity(0.4),
                  90.w,
                  45.h,
                  colorScheme,
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildFluffyCloud(Color color, double width, double height, ColorScheme colorScheme) {
    return AnimatedBuilder(
      animation: floatingAnimation,
      builder: (context, child) {
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            gradient: RadialGradient(
              colors: [
                color,
                color.withOpacity(0.7),
                color.withOpacity(0.3),
              ],
              stops: const [0.3, 0.7, 1.0],
            ),
            borderRadius: BorderRadius.circular(height / 2),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Cloud puffs with slight animation
              Positioned(
                left: width * 0.1,
                top: -height * 0.3 + (3 * math.sin(floatingAnimation.value * math.pi * 4)),
                child: Container(
                  width: width * 0.4,
                  height: width * 0.4,
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      colors: [color, color.withOpacity(0.5)],
                    ),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Positioned(
                right: width * 0.15,
                top: -height * 0.2 + (5 * math.cos(floatingAnimation.value * math.pi * 3)),
                child: Container(
                  width: width * 0.35,
                  height: width * 0.35,
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      colors: [color, color.withOpacity(0.5)],
                    ),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Positioned(
                left: width * 0.3,
                top: -height * 0.4 + (2 * math.sin(floatingAnimation.value * math.pi * 5)),
                child: Container(
                  width: width * 0.3,
                  height: width * 0.3,
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      colors: [color, color.withOpacity(0.5)],
                    ),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFloatingSandParticles(ColorScheme colorScheme) {
    return Stack(
      children: List.generate(8, (index) {
        return AnimatedBuilder(
          animation: Listenable.merge([cloudAnimation, floatingAnimation]),
          builder: (context, child) {
            final delay = index * 0.3;
            final animValue = (cloudAnimation.value + delay) % 1.0;
            final floatValue = (floatingAnimation.value + delay * 0.5) % 1.0;

            final x = 20.w + (MediaQuery.of(context).size.width - 40.w) * animValue;
            final y = 250.h + (100.h * index) % (MediaQuery.of(context).size.height * 0.4) +
                (20 * math.sin(floatValue * math.pi * 2));

            return Positioned(
              left: x,
              top: y,
              child: Transform.rotate(
                angle: floatValue * math.pi * 2,
                child: Container(
                  width: (8 + index % 4).r,
                  height: (8 + index % 4).r,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        colorScheme.primary.withOpacity(0.3),
                        colorScheme.tertiary.withOpacity(0.1),
                      ],
                    ),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }

  Widget _buildStarsAndMoon(ColorScheme colorScheme) {
    return Stack(
      children: [
        // Enhanced moon with breathing effect
        AnimatedBuilder(
          animation: Listenable.merge([sunsetAnimation, floatingAnimation]),
          builder: (context, child) {
            final breathingScale = 0.95 + 0.05 * math.sin(floatingAnimation.value * math.pi * 2);
            return Positioned(
              top: 80.h + (30 * math.sin(sunsetAnimation.value * math.pi)) +
                  (10 * math.cos(floatingAnimation.value * math.pi * 1.5)),
              right: 40.w + (100.w * math.cos(sunsetAnimation.value * math.pi * 0.4)),
              child: Transform.scale(
                scale: breathingScale,
                child: Container(
                  width: 100.r,
                  height: 100.r,
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      colors: [
                        Colors.white,
                        colorScheme.surface,
                        colorScheme.surface.withOpacity(0.8),
                      ],
                      stops: const [0.0, 0.6, 1.0],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withOpacity(0.8),
                        blurRadius: 50,
                        spreadRadius: 20,
                      ),
                      BoxShadow(
                        color: colorScheme.primary.withOpacity(0.3),
                        blurRadius: 100,
                        spreadRadius: 40,
                      ),
                    ],
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          Colors.white,
                          Colors.white.withOpacity(0.9),
                          colorScheme.surface.withOpacity(0.7),
                        ],
                        stops: const [0.0, 0.8, 1.0],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        // Enhanced constellation stars
        ...List.generate(15, (index) => _buildConstellationStar(index, colorScheme)),
      ],
    );
  }

  Widget _buildConstellationStar(int index, ColorScheme colorScheme) {
    return AnimatedBuilder(
      animation: Listenable.merge([starAnimation, floatingAnimation]),
      builder: (context, child) {
        final delay = index * 0.1;
        final animValue = (starAnimation.value + delay) % 1.0;
        final floatValue = (floatingAnimation.value + delay * 0.7) % 1.0;

        final screenWidth = MediaQuery.of(context).size.width;
        final screenHeight = MediaQuery.of(context).size.height;

        final x = 50.w + (index * 40.w) % (screenWidth - 100.w);
        final y = 70.h + (140.h * index) % (screenHeight * 0.6) +
            (20 * math.sin(animValue * math.pi * 2)) +
            (8 * math.cos(floatValue * math.pi * 3));

        final twinkleIntensity = 0.7 + 0.3 * math.sin(animValue * math.pi * 2);
        final scale = 0.6 + 0.4 * math.sin(floatValue * math.pi * 2);

        return Positioned(
          left: x,
          top: y,
          child: Transform.scale(
            scale: scale,
            child: Icon(
              Icons.star,
              color: colorScheme.tertiary.withOpacity(twinkleIntensity),
              size: (12 + index % 10).r,
              shadows: [
                Shadow(
                  color: colorScheme.tertiary.withOpacity(0.8),
                  blurRadius: 15,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAurora(ColorScheme colorScheme) {
    return AnimatedBuilder(
      animation: Listenable.merge([starAnimation, floatingAnimation]),
      builder: (context, child) {
        return Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: MediaQuery.of(context).size.height * 0.4,
          child: CustomPaint(
            painter: AuroraPainter(
              animationValue: starAnimation.value,
              floatingValue: floatingAnimation.value,
              primaryColor: colorScheme.primary,
              tertiaryColor: colorScheme.tertiary,
            ),
          ),
        );
      },
    );
  }

  Widget _buildEnhancedTwinklingStars(ColorScheme colorScheme) {
    return Stack(
      children: List.generate(40, (index) {
        return AnimatedBuilder(
          animation: Listenable.merge([starController, floatingAnimation]),
          builder: (context, child) {
            final delay = index * 0.06;
            final animValue = (starController.value + delay) % 1.0;
            final floatValue = (floatingAnimation.value + delay * 0.8) % 1.0;

            final random = math.Random(index);
            final x = MediaQuery.of(context).size.width * random.nextDouble();
            final y = MediaQuery.of(context).size.height * 0.8 * random.nextDouble();

            final twinkle = math.sin(animValue * math.pi * 8 + index);
            final opacity = 0.2 + 0.8 * ((twinkle + 1) / 2);
            final scale = 0.3 + 0.7 * ((math.sin(floatValue * math.pi * 4) + 1) / 2);

            return Positioned(
              left: x,
              top: y,
              child: Transform.scale(
                scale: scale,
                child: Container(
                  width: (2 + index % 3).r,
                  height: (2 + index % 3).r,
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      colors: [
                        colorScheme.tertiary.withOpacity(opacity),
                        colorScheme.tertiary.withOpacity(opacity * 0.3),
                      ],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.tertiary.withOpacity(opacity * 0.8),
                        blurRadius: 15,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }

  Widget _buildEnhancedDayNightToggle(ColorScheme colorScheme) {
    return AnimatedBuilder(
      animation: Listenable.merge([sunsetAnimation, floatingAnimation]),
      builder: (context, child) {
        final float = 5 * math.sin(floatingAnimation.value * math.pi * 2);
        return Transform.translate(
          offset: Offset(0, float),
          child: GestureDetector(
            onTap: () => onDayNightToggle(!isDarkMode),
            child: Container(
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDarkMode
                      ? [colorScheme.primary, colorScheme.secondary]
                      : [colorScheme.tertiary, colorScheme.primary],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: (isDarkMode ? colorScheme.primary : colorScheme.tertiary)
                        .withOpacity(0.5),
                    blurRadius: 20,
                    spreadRadius: 3,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 600),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return RotationTransition(
                    turns: animation,
                    child: ScaleTransition(scale: animation, child: child),
                  );
                },
                child: Icon(
                  isDarkMode ? Icons.nightlight_round : Icons.wb_sunny_rounded,
                  key: ValueKey(isDarkMode),
                  color: Colors.white,
                  size: 28.r,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 8,
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

  Widget _buildEnhancedSandFooter(ColorScheme colorScheme) {
    return AnimatedBuilder(
      animation: floatingAnimation,
      builder: (context, child) {
        return CustomPaint(
          size: Size(double.infinity, 200.h),
          painter: EnhancedSandFooterPainter(
            isDarkMode: isDarkMode,
            animationValue: floatingAnimation.value,
            primaryColor: colorScheme.primary,
            surfaceColor: colorScheme.surface,
            backgroundColor: colorScheme.background,
          ),
        );
      },
    );
  }
}

// Custom painter for Aurora effect
class AuroraPainter extends CustomPainter {
  final double animationValue;
  final double floatingValue;
  final Color primaryColor;
  final Color tertiaryColor;

  AuroraPainter({
    required this.animationValue,
    required this.floatingValue,
    required this.primaryColor,
    required this.tertiaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 30);

    final path1 = Path();
    final path2 = Path();

    // First aurora wave
    path1.moveTo(0, size.height * 0.3);
    for (double i = 0; i <= size.width; i += 20) {
      final progress = i / size.width;
      final wave1 = math.sin(progress * math.pi * 3 + animationValue * math.pi * 2) * 50;
      final wave2 = math.cos(progress * math.pi * 5 + floatingValue * math.pi * 3) * 30;
      path1.lineTo(i, size.height * 0.3 + wave1 + wave2);
    }
    path1.lineTo(size.width, 0);
    path1.lineTo(0, 0);
    path1.close();

    // Second aurora wave
    path2.moveTo(0, size.height * 0.5);
    for (double i = 0; i <= size.width; i += 20) {
      final progress = i / size.width;
      final wave1 = math.sin(progress * math.pi * 4 + animationValue * math.pi * 1.5) * 40;
      final wave2 = math.cos(progress * math.pi * 6 + floatingValue * math.pi * 2.5) * 25;
      path2.lineTo(i, size.height * 0.5 + wave1 + wave2);
    }
    path2.lineTo(size.width, 0);
    path2.lineTo(0, 0);
    path2.close();

    // Paint aurora layers
    paint.shader = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        primaryColor.withOpacity(0.15),
        primaryColor.withOpacity(0.05),
        Colors.transparent,
      ],
    ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawPath(path1, paint);

    paint.shader = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        tertiaryColor.withOpacity(0.1),
        tertiaryColor.withOpacity(0.03),
        Colors.transparent,
      ],
    ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawPath(path2, paint);
  }

  @override
  bool shouldRepaint(AuroraPainter oldDelegate) =>
      oldDelegate.animationValue != animationValue ||
          oldDelegate.floatingValue != floatingValue;
}