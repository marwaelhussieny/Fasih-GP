// lib/features/home/presentation/widgets/learning_map_layer.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:grad_project/features/home/domain/entities/lesson_entity.dart';
import 'package:grad_project/features/home/presentation/providers/home_provider.dart';
import 'package:grad_project/features/home/presentation/painters/app_painters.dart';
import 'package:grad_project/features/home/presentation/widgets/enhanced_lesson_node.dart';
import 'dart:math' as math;
import 'package:provider/provider.dart';

class LearningMapLayer extends StatefulWidget {
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
  State<LearningMapLayer> createState() => _LearningMapLayerState();
}

class _LearningMapLayerState extends State<LearningMapLayer>
    with TickerProviderStateMixin {
  late AnimationController _pathAnimationController;
  late AnimationController _particleController;
  late Animation<double> _pathAnimation;
  late Animation<double> _particleAnimation;

  @override
  void initState() {
    super.initState();

    _pathAnimationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _particleController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat();

    _pathAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pathAnimationController,
      curve: Curves.easeInOut,
    ));

    _particleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _particleController,
      curve: Curves.linear,
    ));

    // Start path animation when map animation completes
    widget.mapAnimation.addListener(() {
      if (widget.mapAnimation.value > 0.8 && !_pathAnimationController.isAnimating) {
        _pathAnimationController.forward();
      }
    });
  }

  @override
  void dispose() {
    _pathAnimationController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SliverToBoxAdapter(
      child: AnimatedBuilder(
        animation: Listenable.merge([
          widget.mapAnimation,
          _pathAnimation,
          _particleAnimation,
          widget.floatingAnimation,
        ]),
        builder: (context, child) {
          return Transform.scale(
            scale: 0.7 + (0.3 * widget.mapAnimation.value),
            child: Opacity(
              opacity: widget.mapAnimation.value,
              child: Container(
                height: _calculateMapHeight(),
                margin: EdgeInsets.symmetric(horizontal: 40.w),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Enhanced background elements
                    _buildMapBackground(colorScheme),

                    // Animated path with particles
                    _buildEnhancedMapPath(context, colorScheme),

                    // Floating particles along the path
                    _buildPathParticles(context, colorScheme),

                    // Lesson nodes with enhanced animations
                    ...widget.lessons.asMap().entries.map((entry) {
                      final index = entry.key;
                      final lesson = entry.value;
                      final unlocked = widget.isLessonUnlocked(lesson);

                      return _buildEnhancedLessonNode(
                        lesson: lesson,
                        index: index,
                        isUnlocked: unlocked,
                        colorScheme: colorScheme,
                      );
                    }).toList(),

                    // Progress indicators
                    _buildProgressIndicators(colorScheme),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  double _calculateMapHeight() {
    return (widget.lessons.length * 280.h) + 300.h;
  }

  Widget _buildMapBackground(ColorScheme colorScheme) {
    return Positioned.fill(
      child: CustomPaint(
        painter: EnhancedMapBackgroundPainter(
          animationValue: widget.floatingAnimation.value,
          colorScheme: colorScheme,
          isDarkMode: widget.isDarkMode,
        ),
      ),
    );
  }

  Widget _buildEnhancedMapPath(BuildContext context, ColorScheme colorScheme) {
    return Positioned.fill(
      child: CustomPaint(
        painter: EnhancedDottedDesertMapPathPainter(
          progress: _pathAnimation.value,
          lessonCount: widget.lessons.length,
          isDarkMode: widget.isDarkMode,
          colorScheme: colorScheme,
          animationValue: widget.floatingAnimation.value,
          pathAnimation: _pathAnimation.value,
        ),
      ),
    );
  }

  Widget _buildPathParticles(BuildContext context, ColorScheme colorScheme) {
    if (_pathAnimation.value < 0.5) return const SizedBox.shrink();

    return Stack(
      children: List.generate(12, (index) {
        return AnimatedBuilder(
          animation: _particleAnimation,
          builder: (context, child) {
            final delay = index * 0.1;
            final animValue = (_particleAnimation.value + delay) % 1.0;
            final pathProgress = animValue * (widget.lessons.length - 1);

            // Calculate position along the path
            final position = _calculatePathPosition(pathProgress);

            return Positioned(
              left: position.dx,
              top: position.dy,
              child: Transform.scale(
                scale: 0.5 + 0.5 * math.sin(animValue * math.pi * 4),
                child: Container(
                  width: (4 + index % 3).r,
                  height: (4 + index % 3).r,
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      colors: [
                        colorScheme.tertiary,
                        colorScheme.tertiary.withOpacity(0.3),
                      ],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.tertiary.withOpacity(0.6),
                        blurRadius: 8,
                        spreadRadius: 2,
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

  Offset _calculatePathPosition(double progress) {
    final screenWidth = MediaQuery.of(context).size.width - 80.w;
    final lessonIndex = progress.floor();
    final localProgress = progress - lessonIndex;

    // Calculate zigzag pattern
    final isEven = lessonIndex % 2 == 0;
    final startX = isEven ? screenWidth * 0.2 : screenWidth * 0.8;
    final endX = isEven ? screenWidth * 0.8 : screenWidth * 0.2;

    final x = startX + (endX - startX) * localProgress;
    final y = 150.h + (lessonIndex + localProgress) * 280.h;

    return Offset(x, y);
  }

  Widget _buildEnhancedLessonNode({
    required LessonEntity lesson,
    required int index,
    required bool isUnlocked,
    required ColorScheme colorScheme,
  }) {
    final screenWidth = MediaQuery.of(context).size.width - 80.w;
    final isEven = index % 2 == 0;
    final baseX = isEven ? screenWidth * 0.2 : screenWidth * 0.8;
    final baseY = 150.h + index * 280.h;

    return AnimatedBuilder(
      animation: widget.floatingAnimation,
      builder: (context, child) {
        final floatOffset = 8 * math.sin(
            widget.floatingAnimation.value * math.pi * 2 + index * 0.5
        );

        final x = baseX + (15 * math.cos(widget.floatingAnimation.value * math.pi + index));
        final y = baseY + floatOffset;

        return Positioned(
          left: x - 60.w, // Center the node
          top: y - 60.h,  // Center the node
          child: _buildLessonNodeContainer(
            lesson: lesson,
            index: index,
            isUnlocked: isUnlocked,
            colorScheme: colorScheme,
          ),
        );
      },
    );
  }

  Widget _buildLessonNodeContainer({
    required LessonEntity lesson,
    required int index,
    required bool isUnlocked,
    required ColorScheme colorScheme,
  }) {
    return GestureDetector(
      onTap: isUnlocked ? () => widget.showLessonDetails(lesson) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 120.w,
        height: 120.h,
        decoration: BoxDecoration(
          gradient: _getLessonGradient(lesson, isUnlocked, colorScheme),
          shape: BoxShape.circle,
          boxShadow: _getLessonShadows(lesson, isUnlocked, colorScheme),
          border: _getLessonBorder(lesson, isUnlocked, colorScheme),
        ),
        child: Stack(
          children: [
            // Background pattern
            _buildNodeBackgroundPattern(isUnlocked, colorScheme),

            // Main content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Lesson icon
                  Icon(
                    _getLessonIcon(lesson),
                    color: Colors.white,
                    size: 32.r,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 4,
                      ),
                    ],
                  ),

                  SizedBox(height: 8.h),

                  // Lesson number
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Text(
                      '${index + 1}',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Progress ring
            if (lesson.progress > 0)
              _buildProgressRing(lesson.progress, colorScheme),

            // Lock overlay
            if (!isUnlocked)
              _buildLockOverlay(colorScheme),

            // Completion badge
            if (lesson.isCompleted)
              _buildCompletionBadge(colorScheme),
          ],
        ),
      ),
    );
  }

  Widget _buildNodeBackgroundPattern(bool isUnlocked, ColorScheme colorScheme) {
    if (!isUnlocked) return const SizedBox.shrink();

    return Positioned.fill(
      child: ClipOval(
        child: CustomPaint(
          painter: NodeBackgroundPatternPainter(
            animationValue: widget.floatingAnimation.value,
            colorScheme: colorScheme,
          ),
        ),
      ),
    );
  }

  LinearGradient _getLessonGradient(LessonEntity lesson, bool isUnlocked, ColorScheme colorScheme) {
    if (!isUnlocked) {
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          colorScheme.outline.withOpacity(0.4),
          colorScheme.outline.withOpacity(0.2),
        ],
      );
    }

    if (lesson.isCompleted) {
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF4CAF50),
          Color(0xFF66BB6A),
          Color(0xFF81C784),
        ],
        stops: [0.0, 0.6, 1.0],
      );
    }

    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        colorScheme.primary,
        colorScheme.tertiary,
        colorScheme.primary.withOpacity(0.8),
      ],
      stops: const [0.0, 0.6, 1.0],
    );
  }

  List<BoxShadow> _getLessonShadows(LessonEntity lesson, bool isUnlocked, ColorScheme colorScheme) {
    if (!isUnlocked) {
      return [
        BoxShadow(
          color: colorScheme.outline.withOpacity(0.2),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ];
    }

    final shadowColor = lesson.isCompleted
        ? const Color(0xFF4CAF50)
        : colorScheme.primary;

    return [
      BoxShadow(
        color: shadowColor.withOpacity(0.4),
        blurRadius: 20,
        offset: const Offset(0, 10),
        spreadRadius: 0,
      ),
      BoxShadow(
        color: shadowColor.withOpacity(0.2),
        blurRadius: 40,
        offset: const Offset(0, 20),
        spreadRadius: 5,
      ),
    ];
  }

  Border? _getLessonBorder(LessonEntity lesson, bool isUnlocked, ColorScheme colorScheme) {
    if (!isUnlocked) {
      return Border.all(
        color: colorScheme.outline.withOpacity(0.3),
        width: 2,
      );
    }

    if (lesson.isCompleted) {
      return Border.all(
        color: Colors.white.withOpacity(0.3),
        width: 3,
      );
    }

    return Border.all(
      color: Colors.white.withOpacity(0.2),
      width: 2,
    );
  }

  IconData _getLessonIcon(LessonEntity lesson) {
    // You can customize this based on lesson type or content
    if (lesson.isCompleted) return Icons.check_circle_rounded;

    switch (lesson.id.hashCode % 6) {
      case 0: return Icons.abc_rounded;
      case 1: return Icons.quiz_rounded;
      case 2: return Icons.book_rounded;
      case 3: return Icons.mic_rounded;
      case 4: return Icons.edit_rounded;
      case 5: return Icons.games_rounded;
      default: return Icons.school_rounded;
    }
  }

  Widget _buildProgressRing(double progress, ColorScheme colorScheme) {
    return Positioned.fill(
      child: CustomPaint(
        painter: ProgressRingPainter(
          progress: progress,
          colorScheme: colorScheme,
          animationValue: widget.floatingAnimation.value,
        ),
      ),
    );
  }

  Widget _buildLockOverlay(ColorScheme colorScheme) {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.5),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Icon(
            Icons.lock_rounded,
            color: Colors.white.withOpacity(0.8),
            size: 28.r,
          ),
        ),
      ),
    );
  }

  Widget _buildCompletionBadge(ColorScheme colorScheme) {
    return Positioned(
      top: 8.h,
      right: 8.w,
      child: Container(
        padding: EdgeInsets.all(4.r),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Colors.white, Color(0xFFF0F0F0)],
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          Icons.star,
          color: const Color(0xFFFFD700),
          size: 12.r,
        ),
      ),
    );
  }

  Widget _buildProgressIndicators(ColorScheme colorScheme) {
    final completedLessons = widget.lessons.where((l) => l.isCompleted).length;
    final totalLessons = widget.lessons.length;

    if (totalLessons == 0) return const SizedBox.shrink();

    return Positioned(
      top: 50.h,
      left: 20.w,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              colorScheme.surface.withOpacity(0.9),
              colorScheme.background.withOpacity(0.8),
            ],
          ),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: colorScheme.primary.withOpacity(0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: colorScheme.primary.withOpacity(0.1),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.route_rounded,
              color: colorScheme.primary,
              size: 20.r,
            ),
            SizedBox(width: 8.w),
            Text(
              '$completedLessons/$totalLessons',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Enhanced painters for the map
class EnhancedMapBackgroundPainter extends CustomPainter {
  final double animationValue;
  final ColorScheme colorScheme;
  final bool isDarkMode;

  EnhancedMapBackgroundPainter({
    required this.animationValue,
    required this.colorScheme,
    required this.isDarkMode,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);

    // Create flowing background shapes
    for (int i = 0; i < 5; i++) {
      final path = Path();
      final centerX = size.width * (0.2 + i * 0.15);
      final centerY = size.height * (0.1 + i * 0.2);

      final radius = 50 + (30 * math.sin(animationValue * math.pi * 2 + i));

      path.addOval(Rect.fromCircle(
        center: Offset(centerX, centerY),
        radius: radius,
      ));

      paint.color = colorScheme.primaryContainer.withOpacity(0.1);
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(EnhancedMapBackgroundPainter oldDelegate) =>
      oldDelegate.animationValue != animationValue;
}

class EnhancedDottedDesertMapPathPainter extends CustomPainter {
  final double progress;
  final int lessonCount;
  final bool isDarkMode;
  final ColorScheme colorScheme;
  final double animationValue;
  final double pathAnimation;

  EnhancedDottedDesertMapPathPainter({
    required this.progress,
    required this.lessonCount,
    required this.isDarkMode,
    required this.colorScheme,
    required this.animationValue,
    required this.pathAnimation,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = colorScheme.primary.withOpacity(0.6)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final lessonSpacing = size.height / (lessonCount + 1);

    // Create zigzag path
    for (int i = 0; i < lessonCount; i++) {
      final y = lessonSpacing * (i + 1);
      final isEven = i % 2 == 0;
      final x = isEven ? size.width * 0.2 : size.width * 0.8;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        // Create curved connection
        final prevY = lessonSpacing * i;
        final prevIsEven = (i - 1) % 2 == 0;
        final prevX = prevIsEven ? size.width * 0.2 : size.width * 0.8;

        final controlX = (prevX + x) / 2;
        final controlY = (prevY + y) / 2;

        path.quadraticBezierTo(controlX, controlY, x, y);
      }
    }

    // Draw animated dotted path
    final pathMetrics = path.computeMetrics();
    for (final pathMetric in pathMetrics) {
      final length = pathMetric.length;
      const dashWidth = 15.0;
      const dashSpace = 10.0;

      double distance = 0;
      while (distance < length * pathAnimation) {
        final startDistance = distance;
        final endDistance = math.min(distance + dashWidth, length * pathAnimation);

        if (startDistance < length && endDistance <= length) {
          final startPoint = pathMetric.getTangentForOffset(startDistance);
          final endPoint = pathMetric.getTangentForOffset(endDistance);

          if (startPoint != null && endPoint != null) {
            // Add glow effect
            final glowPaint = Paint()
              ..color = colorScheme.primary.withOpacity(0.3)
              ..strokeWidth = 8
              ..style = PaintingStyle.stroke
              ..strokeCap = StrokeCap.round
              ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

            canvas.drawLine(startPoint.position, endPoint.position, glowPaint);
            canvas.drawLine(startPoint.position, endPoint.position, paint);
          }
        }

        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(EnhancedDottedDesertMapPathPainter oldDelegate) =>
      oldDelegate.progress != progress ||
          oldDelegate.animationValue != animationValue ||
          oldDelegate.pathAnimation != pathAnimation;
}

class NodeBackgroundPatternPainter extends CustomPainter {
  final double animationValue;
  final ColorScheme colorScheme;

  NodeBackgroundPatternPainter({
    required this.animationValue,
    required this.colorScheme,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.white.withOpacity(0.1);

    final centerX = size.width / 2;
    final centerY = size.height / 2;

    // Create animated concentric circles
    for (int i = 0; i < 3; i++) {
      final radius = (20 + i * 15) + (5 * math.sin(animationValue * math.pi * 2 + i));
      final opacity = 0.1 - (i * 0.03);

      paint.color = Colors.white.withOpacity(opacity);
      canvas.drawCircle(Offset(centerX, centerY), radius, paint);
    }
  }

  @override
  bool shouldRepaint(NodeBackgroundPatternPainter oldDelegate) =>
      oldDelegate.animationValue != animationValue;
}

class ProgressRingPainter extends CustomPainter {
  final double progress;
  final ColorScheme colorScheme;
  final double animationValue;

  ProgressRingPainter({
    required this.progress,
    required this.colorScheme,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 4;

    // Background ring
    final backgroundPaint = Paint()
      ..color = Colors.white.withOpacity(0.2)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Progress ring
    final progressPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * math.pi * progress;
    final startAngle = -math.pi / 2; // Start from top

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(ProgressRingPainter oldDelegate) =>
      oldDelegate.progress != progress ||
          oldDelegate.animationValue != animationValue;
}