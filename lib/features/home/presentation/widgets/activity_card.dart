// lib/features/home/presentation/widgets/activity_card.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:grad_project/features/home/domain/entities/lesson_activity_entity.dart';
import 'dart:math' as math;

class ActivityCard extends StatefulWidget {
  final LessonActivityEntity activity;
  final bool isUnlocked;
  final String lessonId;
  final bool isDarkMode;
  final Function(BuildContext context, LessonActivityEntity activity, String lessonId) handleActivityTap;
  final Animation<double>? floatingAnimation; // Optional floating animation

  const ActivityCard({
    Key? key,
    required this.activity,
    required this.isUnlocked,
    required this.lessonId,
    required this.isDarkMode,
    required this.handleActivityTap,
    this.floatingAnimation,
  }) : super(key: key);

  @override
  State<ActivityCard> createState() => _ActivityCardState();
}

class _ActivityCardState extends State<ActivityCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _hoverController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _hoverController,
      curve: Curves.easeInOut,
    ));

    _elevationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _hoverController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  void _onHover(bool isHovered) {
    if (!widget.isUnlocked) return;

    setState(() {
      _isHovered = isHovered;
    });

    if (isHovered) {
      _hoverController.forward();
    } else {
      _hoverController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final activityConfig = _getActivityConfig(colorScheme);

    return AnimatedBuilder(
      animation: Listenable.merge([
        _hoverController,
        widget.floatingAnimation ?? const AlwaysStoppedAnimation(0.0),
      ]),
      builder: (context, child) {
        final floatOffset = widget.floatingAnimation != null
            ? 3 * math.sin(widget.floatingAnimation!.value * math.pi * 2)
            : 0.0;

        return Transform.translate(
          offset: Offset(0, floatOffset),
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: MouseRegion(
              onEnter: (_) => _onHover(true),
              onExit: (_) => _onHover(false),
              child: GestureDetector(
                onTap: widget.isUnlocked
                    ? () => widget.handleActivityTap(context, widget.activity, widget.lessonId)
                    : null,
                onTapDown: widget.isUnlocked ? (_) => _hoverController.forward() : null,
                onTapUp: widget.isUnlocked ? (_) => _hoverController.reverse() : null,
                onTapCancel: widget.isUnlocked ? () => _hoverController.reverse() : null,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: _buildCardGradient(activityConfig, colorScheme),
                    borderRadius: BorderRadius.circular(28.r),
                    boxShadow: _buildCardShadows(activityConfig, colorScheme),
                    border: _buildCardBorder(activityConfig, colorScheme),
                  ),
                  child: Stack(
                    children: [
                      // Background pattern
                      _buildBackgroundPattern(),

                      // Main content
                      Padding(
                        padding: EdgeInsets.all(20.w),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Activity icon with animation
                            _buildAnimatedIcon(activityConfig),

                            SizedBox(height: 16.h),

                            // Activity title
                            _buildActivityTitle(colorScheme),

                            SizedBox(height: 8.h),

                            // Progress indicator
                            _buildProgressIndicator(colorScheme),
                          ],
                        ),
                      ),

                      // Completion badge
                      if (widget.activity.isCompleted)
                        _buildCompletionBadge(colorScheme),

                      // Lock overlay for disabled activities
                      if (!widget.isUnlocked)
                        _buildLockOverlay(colorScheme),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  ActivityConfig _getActivityConfig(ColorScheme colorScheme) {
    switch (widget.activity.type) {
      case LessonActivityType.quiz:
        return ActivityConfig(
          icon: Icons.quiz_rounded,
          gradient: widget.isDarkMode
              ? [const Color(0xFF4A148C), const Color(0xFF6A1B9A)]
              : [const Color(0xFF9C27B0), const Color(0xFFBA68C8)],
          shadowColor: const Color(0xFF9C27B0),
        );
      case LessonActivityType.writing:
        return ActivityConfig(
          icon: Icons.edit_rounded,
          gradient: widget.isDarkMode
              ? [const Color(0xFF0D47A1), const Color(0xFF1565C0)]
              : [const Color(0xFF2196F3), const Color(0xFF64B5F6)],
          shadowColor: const Color(0xFF2196F3),
        );
      case LessonActivityType.speaking:
        return ActivityConfig(
          icon: Icons.mic_rounded,
          gradient: widget.isDarkMode
              ? [const Color(0xFFAD1457), const Color(0xFFC2185B)]
              : [const Color(0xFFE91E63), const Color(0xFFF06292)],
          shadowColor: const Color(0xFFE91E63),
        );
      case LessonActivityType.flashcards:
        return ActivityConfig(
          icon: Icons.layers_rounded,
          gradient: widget.isDarkMode
              ? [const Color(0xFF2E7D32), const Color(0xFF388E3C)]
              : [const Color(0xFF4CAF50), const Color(0xFF81C784)],
          shadowColor: const Color(0xFF4CAF50),
        );
      case LessonActivityType.grammar:
        return ActivityConfig(
          icon: Icons.menu_book_rounded,
          gradient: [colorScheme.primary, colorScheme.tertiary],
          shadowColor: colorScheme.primary,
        );
      case LessonActivityType.wordle:
        return ActivityConfig(
          icon: Icons.games_rounded,
          gradient: widget.isDarkMode
              ? [const Color(0xFF6A1B9A), const Color(0xFF8E24AA)]
              : [const Color(0xFF673AB7), const Color(0xFF9575CD)],
          shadowColor: const Color(0xFF673AB7),
        );
      default:
        return ActivityConfig(
          icon: Icons.help_rounded,
          gradient: [colorScheme.outline, colorScheme.outline.withOpacity(0.8)],
          shadowColor: colorScheme.outline,
        );
    }
  }

  LinearGradient _buildCardGradient(ActivityConfig config, ColorScheme colorScheme) {
    if (!widget.isUnlocked) {
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          colorScheme.outline.withOpacity(0.3),
          colorScheme.outline.withOpacity(0.2),
        ],
      );
    }

    if (widget.activity.isCompleted) {
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFF4CAF50),
          const Color(0xFF66BB6A),
          const Color(0xFF81C784),
        ],
        stops: const [0.0, 0.6, 1.0],
      );
    }

    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        config.gradient[0],
        config.gradient[1],
        if (config.gradient.length > 1)
          config.gradient[1].withOpacity(0.8),
      ],
      stops: const [0.0, 0.7, 1.0],
    );
  }

  List<BoxShadow> _buildCardShadows(ActivityConfig config, ColorScheme colorScheme) {
    if (!widget.isUnlocked) {
      return [
        BoxShadow(
          color: colorScheme.outline.withOpacity(0.2),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ];
    }

    final shadowColor = widget.activity.isCompleted
        ? const Color(0xFF4CAF50)
        : config.shadowColor;

    return [
      BoxShadow(
        color: shadowColor.withOpacity(0.3 + (_elevationAnimation.value * 0.2)),
        blurRadius: 15 + (_elevationAnimation.value * 10),
        offset: Offset(0, 6 + (_elevationAnimation.value * 8)),
        spreadRadius: _elevationAnimation.value * 2,
      ),
      if (_isHovered && widget.isUnlocked)
        BoxShadow(
          color: shadowColor.withOpacity(0.1),
          blurRadius: 30,
          offset: const Offset(0, 15),
          spreadRadius: 5,
        ),
    ];
  }

  Border? _buildCardBorder(ActivityConfig config, ColorScheme colorScheme) {
    if (!widget.isUnlocked) {
      return Border.all(
        color: colorScheme.outline.withOpacity(0.3),
        width: 1,
      );
    }

    if (_isHovered) {
      final borderColor = widget.activity.isCompleted
          ? const Color(0xFF4CAF50)
          : config.shadowColor;

      return Border.all(
        color: borderColor.withOpacity(0.5),
        width: 2,
      );
    }

    return null;
  }

  Widget _buildBackgroundPattern() {
    return Positioned.fill(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28.r),
        child: CustomPaint(
          painter: ActivityBackgroundPatternPainter(
            isUnlocked: widget.isUnlocked,
            isCompleted: widget.activity.isCompleted,
            animationValue: widget.floatingAnimation?.value ?? 0.0,
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedIcon(ActivityConfig config) {
    return AnimatedBuilder(
      animation: widget.floatingAnimation ?? const AlwaysStoppedAnimation(0.0),
      builder: (context, child) {
        final pulseScale = widget.floatingAnimation != null
            ? 1.0 + 0.1 * math.sin(widget.floatingAnimation!.value * math.pi * 3)
            : 1.0;

        return Transform.scale(
          scale: pulseScale,
          child: Container(
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Icon(
              widget.activity.isCompleted ? Icons.check_circle_rounded : config.icon,
              color: Colors.white,
              size: 36.r,
              shadows: [
                Shadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 8,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildActivityTitle(ColorScheme colorScheme) {
    return Text(
      widget.activity.title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        shadows: [
          Shadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 4,
          ),
        ],
      ),
      textAlign: TextAlign.center,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildProgressIndicator(ColorScheme colorScheme) {
    if (!widget.isUnlocked) {
      return const SizedBox.shrink();
    }

    return Container(
      height: 4.h,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.3),
        borderRadius: BorderRadius.circular(2.r),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: widget.activity.isCompleted ? 1.0 : 0.0,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white,
                Colors.white.withOpacity(0.8),
              ],
            ),
            borderRadius: BorderRadius.circular(2.r),
          ),
        ),
      ),
    );
  }

  Widget _buildCompletionBadge(ColorScheme colorScheme) {
    return Positioned(
      top: 12.w,
      right: 12.w,
      child: Container(
        padding: EdgeInsets.all(6.r),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Colors.white, Color(0xFFF0F0F0)],
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          Icons.check,
          color: const Color(0xFF4CAF50),
          size: 16.r,
        ),
      ),
    );
  }

  Widget _buildLockOverlay(ColorScheme colorScheme) {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.6),
          borderRadius: BorderRadius.circular(28.r),
        ),
        child: Center(
          child: Icon(
            Icons.lock_rounded,
            color: Colors.white.withOpacity(0.8),
            size: 32.r,
          ),
        ),
      ),
    );
  }
}

class ActivityConfig {
  final IconData icon;
  final List<Color> gradient;
  final Color shadowColor;

  ActivityConfig({
    required this.icon,
    required this.gradient,
    required this.shadowColor,
  });
}

class ActivityBackgroundPatternPainter extends CustomPainter {
  final bool isUnlocked;
  final bool isCompleted;
  final double animationValue;

  ActivityBackgroundPatternPainter({
    required this.isUnlocked,
    required this.isCompleted,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (!isUnlocked) return;

    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.white.withOpacity(0.1);

    // Create subtle geometric pattern
    final path = Path();
    final patternSize = size.width * 0.3;

    for (double i = 0; i < size.width + patternSize; i += patternSize) {
      for (double j = 0; j < size.height + patternSize; j += patternSize) {
        final offset = math.sin(animationValue * math.pi * 2) * 10;
        path.addOval(Rect.fromCircle(
          center: Offset(i + offset, j - offset),
          radius: 2,
        ));
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(ActivityBackgroundPatternPainter oldDelegate) =>
      oldDelegate.animationValue != animationValue ||
          oldDelegate.isUnlocked != isUnlocked ||
          oldDelegate.isCompleted != isCompleted;
}