// lib/features/home/presentation/widgets/enhanced_lesson_node.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:grad_project/features/home/domain/entities/lesson_entity.dart';
import 'package:grad_project/features/home/presentation/providers/home_provider.dart';
import 'package:grad_project/features/home/presentation/painters/app_painters.dart';
import 'package:grad_project/features/home/presentation/screens/home_screen.dart'; // Import colors
import 'dart:math' as math;

// Helper class for lesson node themes
class LessonTheme {
  final List<Color> gradient;
  final Color shadowColor;
  final IconData icon;

  LessonTheme({
    required this.gradient,
    required this.shadowColor,
    required this.icon,
  });
}

class EnhancedLessonNode extends StatelessWidget {
  final LessonEntity lesson;
  final bool isLessonUnlocked;
  final HomeProvider homeProvider;
  final int index;
  final Animation<double> mapAnimation;
  final Animation<double> floatingAnimation;
  final bool isDarkMode;
  final Function(LessonEntity lesson) showLessonDetails; // Simplified callback

  const EnhancedLessonNode({
    Key? key,
    required this.lesson,
    required this.isLessonUnlocked,
    required this.homeProvider,
    required this.index,
    required this.mapAnimation,
    required this.floatingAnimation,
    required this.isDarkMode,
    required this.showLessonDetails,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeightOfMap = (homeProvider.lessons.length * 250.h) + 200.h;

    final t = (index + 1) / (homeProvider.lessons.length + 1);
    final amplitude = screenWidth * 0.10; // Reduced amplitude further
    final baseX = screenWidth * 0.5 + amplitude * math.sin(t * math.pi * 2.2);
    final y = screenHeightOfMap * 0.12 + (screenHeightOfMap * 0.7) * t;

    // Calculate safe positioning with proper margins for badge overflow
    // Node size: 80.w + Badge overflow on right: 20.w + Extra margin: 20.w = 120.w total needed
    final nodeRadius = 40.w; // Half of node width (80.w)
    final badgeOverflow = 20.w; // Badge extends 20.w beyond node edge
    final safeMargin = 30.w; // Additional safety margin

    final minLeft = safeMargin;
    final maxLeft = screenWidth - (nodeRadius * 2) - badgeOverflow - safeMargin;
    final safeLeft = math.max(minLeft, math.min(maxLeft, baseX - nodeRadius));

    final completedActivities = lesson.activities.where((a) => a.isCompleted).length;
    final totalActivities = lesson.activities.length;
    final progress = totalActivities > 0 ? completedActivities / totalActivities : 0.0;
    final isCompleted = progress == 1.0;

    final List<LessonTheme> desertLessonThemes = isDarkMode ? [
      LessonTheme(
        gradient: [nightBlue, darkPurple],
        shadowColor: nightBlue,
        icon: Icons.menu_book_rounded,
      ),
      LessonTheme(
        gradient: [const Color(0xFF4A148C), const Color(0xFF6A1B9A)],
        shadowColor: const Color(0xFF4A148C),
        icon: Icons.school_rounded,
      ),
      LessonTheme(
        gradient: [const Color(0xFF1565C0), const Color(0xFF1976D2)],
        shadowColor: const Color(0xFF1565C0),
        icon: Icons.auto_stories_rounded,
      ),
      LessonTheme(
        gradient: [const Color(0xFF2E7D32), const Color(0xFF388E3C)],
        shadowColor: const Color(0xFF2E7D32),
        icon: Icons.psychology_rounded,
      ),
      LessonTheme(
        gradient: [starGold, const Color(0xFFFFE082)],
        shadowColor: starGold,
        icon: Icons.lightbulb_rounded,
      ),
    ] : [
      LessonTheme(
        gradient: [primaryOrange, lightOrange],
        shadowColor: primaryOrange,
        icon: Icons.menu_book_rounded,
      ),
      LessonTheme(
        gradient: [lightOrange, warmAmber],
        shadowColor: lightOrange,
        icon: Icons.school_rounded,
      ),
      LessonTheme(
        gradient: [warmAmber, softPeach],
        shadowColor: warmAmber,
        icon: Icons.auto_stories_rounded,
      ),
      LessonTheme(
        gradient: [const Color(0xFFFF7043), const Color(0xFFFFAB91)],
        shadowColor: const Color(0xFFFF7043),
        icon: Icons.psychology_rounded,
      ),
      LessonTheme(
        gradient: [primaryOrange, desertSand],
        shadowColor: primaryOrange,
        icon: Icons.lightbulb_rounded,
      ),
    ];

    final themeData = desertLessonThemes[index % desertLessonThemes.length];

    return AnimatedBuilder(
      animation: mapAnimation,
      builder: (context, child) {
        final delay = index * 0.12;
        final nodeProgress = math.max(0.0, math.min(1.0, (mapAnimation.value - delay) / (1.0 - delay)));
        final nodeAnimation = Curves.elasticOut.transform(nodeProgress);

        return Positioned(
          left: safeLeft,
          top: y - 40.h,
          child: Transform.scale(
            scale: nodeAnimation,
            child: GestureDetector(
              onTap: isLessonUnlocked ? () => showLessonDetails(lesson) : null,
              child: Container(
                width: 80.w,
                height: 80.w,
                decoration: BoxDecoration(
                  gradient: isLessonUnlocked
                      ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isCompleted
                        ? [const Color(0xFF4CAF50), const Color(0xFF66BB6A)]
                        : themeData.gradient,
                  )
                      : LinearGradient(
                    colors: [
                      Colors.grey.shade400,
                      Colors.grey.shade500,
                    ],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: isLessonUnlocked
                          ? (isCompleted ? Colors.green : themeData.shadowColor).withOpacity(0.4)
                          : Colors.grey.withOpacity(0.3),
                      spreadRadius: 0,
                      blurRadius: 25,
                      offset: const Offset(0, 12),
                    ),
                  ],
                  border: Border.all(
                    color: Colors.white.withOpacity(0.4),
                    width: 2.5.w,
                  ),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Icon(
                        isCompleted
                            ? Icons.check_circle_rounded
                            : isLessonUnlocked
                            ? themeData.icon
                            : Icons.lock_rounded,
                        color: Colors.white,
                        size: isCompleted ? 36.r : 28.r,
                      ),
                    ),
                    if (isLessonUnlocked && progress > 0 && !isCompleted)
                      Positioned.fill(
                        child: CustomPaint(
                          painter: CircularProgressPainter(
                            progress: progress,
                            color: Colors.white,
                            strokeWidth: 5.w,
                          ),
                        ),
                      ),
                    // Fixed badge positioning - moved further inside to prevent cutoff
                    Positioned(
                      top: -4.h, // Moved down from -8.h
                      right: -4.w, // Moved left from -8.w
                      child: Container(
                        width: 28.w,
                        height: 28.w,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: isCompleted
                                ? [Colors.green, Colors.green.shade700!]
                                : isLessonUnlocked
                                ? [Colors.white, Colors.white.withOpacity(0.95)]
                                : [Colors.grey, Colors.grey.shade600!],
                          ),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isLessonUnlocked ? themeData.gradient[0] : Colors.grey,
                            width: 2.w,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.25),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            '${lesson.order}',
                            style: TextStyle(
                              color: isCompleted
                                  ? Colors.white
                                  : isLessonUnlocked
                                  ? themeData.gradient[0]
                                  : Colors.white,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (isLessonUnlocked && !isCompleted)
                      Positioned.fill(
                        child: AnimatedBuilder(
                          animation: floatingAnimation,
                          builder: (context, child) {
                            final glowOpacity = 0.3 + 0.2 * math.sin(floatingAnimation.value * math.pi * 2);
                            return Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: themeData.gradient[0].withOpacity(glowOpacity),
                                    blurRadius: 30,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                            );
                          },
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