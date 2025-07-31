// lib/features/home/presentation/widgets/learning_map_layer.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:grad_project/features/home/domain/entities/lesson_entity.dart';
import 'package:grad_project/features/home/presentation/providers/home_provider.dart';
// Updated import to the consolidated painters file
import 'package:grad_project/features/home/presentation/painters/app_painters.dart';
import 'package:grad_project/features/home/presentation/widgets/enhanced_lesson_node.dart';
import 'dart:math' as math;
import 'package:provider/provider.dart'; // Added this import

class LearningMapLayer extends StatelessWidget {
  final Animation<double> mapAnimation;
  final List<LessonEntity> lessons;
  final bool isDarkMode;
  final Function(LessonEntity lesson) isLessonUnlocked;
  final Animation<double> floatingAnimation;
  final Function(LessonEntity lesson) showLessonDetails;

  const LearningMapLayer({
    Key? key,
    required this.mapAnimation,
    required this.lessons,
    required this.isDarkMode,
    required this.isLessonUnlocked,
    required this.floatingAnimation,
    required this.showLessonDetails,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: AnimatedBuilder(
        animation: mapAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: 0.8 + (0.2 * mapAnimation.value),
            child: Opacity(
              opacity: mapAnimation.value,
              child: Container(
                height: (lessons.length * 250.h) + 200.h,
                // Increased horizontal margin to accommodate nodes with badges
                margin: EdgeInsets.symmetric(horizontal: 60.w),
                child: Stack(
                  // Allow overflow to prevent clipping of shadows and badges
                  clipBehavior: Clip.none,
                  children: [
                    _buildDottedMapPath(context, lessons.length),
                    ...lessons.asMap().entries.map((entry) {
                      final index = entry.key;
                      final lesson = entry.value;
                      final unlocked = isLessonUnlocked(lesson);

                      return EnhancedLessonNode(
                        lesson: lesson,
                        isLessonUnlocked: unlocked,
                        homeProvider: Provider.of<HomeProvider>(context),
                        index: index,
                        mapAnimation: mapAnimation,
                        floatingAnimation: floatingAnimation,
                        isDarkMode: isDarkMode,
                        showLessonDetails: showLessonDetails,
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDottedMapPath(BuildContext context, int lessonCount) {
    return CustomPaint(
      size: Size(
        // Adjusted width to match the container width
        MediaQuery.of(context).size.width - 120.w,
        (lessonCount * 250.h) + 200.h,
      ),
      painter: DottedDesertMapPathPainter(
        progress: mapAnimation.value,
        lessonCount: lessonCount,
        isDarkMode: isDarkMode,
      ),
    );
  }
}