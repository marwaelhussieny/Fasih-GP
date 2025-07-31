// lib/features/home/presentation/widgets/background_layer.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:grad_project/features/home/presentation/painters/app_painters.dart';
import 'package:grad_project/features/home/presentation/screens/home_screen.dart'; // Import colors
import 'dart:math' as math;

class BackgroundLayer extends StatelessWidget {
  final bool isDarkMode;
  final Animation<double> sunsetAnimation;
  final Animation<double> starAnimation;
  final Animation<double> cloudAnimation;
  final AnimationController starController;
  final Animation<double> floatingAnimation; // For sand footer
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
    return Stack(
      children: [
        // Desert dunes background
        _buildDesertDunes(),

        // Floating particles
        _buildFloatingParticles(),

        // Moving clouds for day mode or stars/moon for night mode
        if (!isDarkMode) ...[
          _buildEnhancedClouds(),
        ] else ...[
          _buildStarsAndMoon(),
        ],

        // Twinkling stars for night mode
        if (isDarkMode) _buildTwinklingStars(),

        // Day/Night toggle button
        Positioned(
          top: 60.h,
          right: 20.w,
          child: _buildDayNightToggle(),
        ),

        // Sand footer at the very bottom
        Align(
          alignment: Alignment.bottomCenter,
          child: SizedBox(
            height: 200.h,
            width: double.infinity,
            child: _buildEnhancedSandFooter(),
          ),
        ),
      ],
    );
  }

  Widget _buildDesertDunes() {
    return Positioned.fill(
      child: CustomPaint(
        painter: EnhancedDesertDunesPainter(
          isDarkMode: isDarkMode,
          animationValue: sunsetAnimation.value,
        ),
      ),
    );
  }

  Widget _buildFloatingParticles() {
    return Stack(
      children: List.generate(15, (index) {
        return AnimatedBuilder(
          animation: starAnimation,
          builder: (context, child) {
            final offset = (index * 0.2) % 1.0;
            final animValue = (starAnimation.value + offset) % 1.0;
            final x = 30.w + (MediaQuery.of(context).size.width - 60.w) *
                (index / 15 + animValue * 0.1) % 1.0;
            final y = 100.h + (MediaQuery.of(context).size.height * 0.8) *
                (animValue + math.sin(animValue * math.pi * 4) * 0.1);

            return Positioned(
              left: x,
              top: y,
              child: Container(
                width: (2 + index % 4).r,
                height: (2 + index % 4).r,
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? starGold.withOpacity(0.8)
                      : warmAmber.withOpacity(0.6),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: (isDarkMode ? starGold : warmAmber).withOpacity(0.5),
                      blurRadius: isDarkMode ? 8 : 4,
                      spreadRadius: isDarkMode ? 2 : 1,
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }

  Widget _buildEnhancedClouds() {
    return Stack(
      children: [
        AnimatedBuilder(
          animation: cloudAnimation,
          builder: (context, child) {
            return Positioned(
              top: 60.h + (20 * math.sin(cloudAnimation.value * math.pi * 2)),
              right: -80.w + (MediaQuery.of(context).size.width * cloudAnimation.value * 0.3),
              child: Transform.scale(
                scale: 0.8,
                child: _buildFluffyCloud(Colors.white.withOpacity(0.7), 120.w, 60.h),
              ),
            );
          },
        ),
        AnimatedBuilder(
          animation: cloudAnimation,
          builder: (context, child) {
            return Positioned(
              top: 140.h + (15 * math.cos(cloudAnimation.value * math.pi * 1.5)),
              left: -100.w + (MediaQuery.of(context).size.width * cloudAnimation.value * 0.25),
              child: Transform.scale(
                scale: 0.6,
                child: _buildFluffyCloud(Colors.white.withOpacity(0.5), 100.w, 50.h),
              ),
            );
          },
        ),
        AnimatedBuilder(
          animation: cloudAnimation,
          builder: (context, child) {
            return Positioned(
              top: 200.h + (10 * math.sin(cloudAnimation.value * math.pi * 2.5)),
              right: -60.w + (MediaQuery.of(context).size.width * cloudAnimation.value * 0.4),
              child: Transform.scale(
                scale: 0.4,
                child: _buildFluffyCloud(desertSand.withOpacity(0.3), 80.w, 40.h),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildFluffyCloud(Color color, double width, double height) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(height / 2),
      ),
      child: Stack(
        children: [
          Positioned(
            left: width * 0.1,
            top: -height * 0.3,
            child: Container(
              width: width * 0.4,
              height: width * 0.4,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            right: width * 0.15,
            top: -height * 0.2,
            child: Container(
              width: width * 0.35,
              height: width * 0.35,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            left: width * 0.3,
            top: -height * 0.4,
            child: Container(
              width: width * 0.3,
              height: width * 0.3,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStarsAndMoon() {
    return Stack(
      children: [
        AnimatedBuilder(
          animation: sunsetAnimation,
          builder: (context, child) {
            return Positioned(
              top: 80.h + (25 * math.sin(sunsetAnimation.value * math.pi)),
              right: 40.w + (80.w * math.cos(sunsetAnimation.value * math.pi * 0.3)),
              child: Container(
                width: 90.r,
                height: 90.r,
                decoration: BoxDecoration(
                  color: moonSilver,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: moonSilver.withOpacity(0.8),
                      blurRadius: 40,
                      spreadRadius: 15,
                    ),
                    BoxShadow(
                      color: Colors.white.withOpacity(0.3),
                      blurRadius: 80,
                      spreadRadius: 30,
                    ),
                  ],
                ),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Colors.white,
                        moonSilver,
                        moonSilver.withOpacity(0.8),
                      ],
                      stops: const [0.0, 0.7, 1.0],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        ...List.generate(12, (index) => _buildConstellationStar(index)),
      ],
    );
  }

  Widget _buildConstellationStar(int index) {
    return AnimatedBuilder(
      animation: starAnimation,
      builder: (context, child) {
        final delay = index * 0.12;
        final animValue = (starAnimation.value + delay) % 1.0;
        final x = 50.w + (index * 35.w) % (MediaQuery.of(context).size.width - 100.w);
        final y = 70.h + (120.h * index) % (MediaQuery.of(context).size.height * 0.6) +
            (15 * math.sin(animValue * math.pi * 2));

        return Positioned(
          left: x,
          top: y,
          child: Transform.scale(
            scale: 0.7 + 0.5 * math.sin(animValue * math.pi * 2),
            child: Icon(
              Icons.star,
              color: starGold.withOpacity(0.7 + 0.3 * math.sin(animValue * math.pi * 2)),
              size: (10 + index % 8).r,
            ),
          ),
        );
      },
    );
  }

  Widget _buildTwinklingStars() {
    return Stack(
      children: List.generate(30, (index) {
        return AnimatedBuilder(
          animation: starController,
          builder: (context, child) {
            final delay = index * 0.08;
            final animValue = (starController.value + delay) % 1.0;
            final x = (MediaQuery.of(context).size.width * math.Random(index).nextDouble());
            final y = (MediaQuery.of(context).size.height * 0.7 * math.Random(index + 100).nextDouble());

            final twinkle = math.sin(animValue * math.pi * 6);
            final opacity = 0.3 + 0.7 * ((twinkle + 1) / 2);
            final scale = 0.4 + 0.6 * ((twinkle + 1) / 2);

            return Positioned(
              left: x,
              top: y,
              child: Transform.scale(
                scale: scale,
                child: Container(
                  width: 3.r,
                  height: 3.r,
                  decoration: BoxDecoration(
                    color: starGold.withOpacity(opacity),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: starGold.withOpacity(opacity * 0.6),
                        blurRadius: 10,
                        spreadRadius: 3,
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

  Widget _buildDayNightToggle() {
    return AnimatedBuilder(
      animation: sunsetAnimation,
      builder: (context, child) {
        return GestureDetector(
          onTap: () => onDayNightToggle(!isDarkMode),
          child: Container(
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDarkMode
                    ? [nightBlue, darkPurple]
                    : [lightOrange, primaryOrange],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: (isDarkMode ? nightBlue : primaryOrange).withOpacity(0.4),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return ScaleTransition(scale: animation, child: child);
              },
              child: Icon(
                isDarkMode ? Icons.nightlight_round : Icons.wb_sunny_rounded,
                key: ValueKey(isDarkMode),
                color: Colors.white,
                size: 24.r,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEnhancedSandFooter() {
    return CustomPaint(
      size: Size(double.infinity, 200.h),
      painter: EnhancedSandFooterPainter(
        isDarkMode: isDarkMode,
        animationValue: floatingAnimation.value,
      ),
    );
  }
}
