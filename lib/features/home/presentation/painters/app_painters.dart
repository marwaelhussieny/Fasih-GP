// lib/features/home/presentation/painters/app_painters.dart

import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:ui'; // Required for PathMetrics
import 'package:flutter_screenutil/flutter_screenutil.dart'; // For .w and .h

// EnhancedDesertDunesPainter
class EnhancedDesertDunesPainter extends CustomPainter {
  final bool isDarkMode;
  final double animationValue;
  final Color primaryColor; // Add missing parameter
  final Color surfaceColor; // Add missing parameter
  final Color backgroundColor; // Add missing parameter

  EnhancedDesertDunesPainter({
    required this.isDarkMode,
    required this.animationValue,
    required this.primaryColor, // Make required
    required this.surfaceColor, // Make required
    required this.backgroundColor, // Make required
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    if (isDarkMode) {
      _drawDuneLayer(canvas, size, paint,
          const Color(0xFF2E2A54).withOpacity(0.4), 0.8, 0.7);
      _drawDuneLayer(canvas, size, paint,
          const Color(0xFF3D2F7C).withOpacity(0.3), 0.7, 0.5);
      _drawDuneLayer(canvas, size, paint,
          const Color(0xFF4A3A8B).withOpacity(0.2), 0.6, 0.3);
    } else {
      _drawDuneLayer(canvas, size, paint,
          const Color(0xFFE6B887).withOpacity(0.4), 0.8, 0.7);
      _drawDuneLayer(canvas, size, paint,
          const Color(0xFFD4955F).withOpacity(0.3), 0.7, 0.5);
      _drawDuneLayer(canvas, size, paint,
          const Color(0xFFC78642).withOpacity(0.2), 0.6, 0.3);
    }
  }

  void _drawDuneLayer(Canvas canvas, Size size, Paint paint,
      Color color, double heightFactor, double yOffset) {
    paint.color = color;

    final path = Path();
    path.moveTo(0, size.height);

    for (double x = 0; x <= size.width; x += 15) {
      final y = size.height * yOffset +
          math.sin((x / size.width * math.pi * 4) + (animationValue * math.pi * 2)) *
              size.height * heightFactor * 0.08 +
          math.sin((x / size.width * math.pi * 6) + (animationValue * math.pi * 1.5)) *
              size.height * heightFactor * 0.05;
      path.lineTo(x, y);
    }

    path.lineTo(size.width, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

// DottedDesertMapPathPainter
class DottedDesertMapPathPainter extends CustomPainter {
  final double progress;
  final int lessonCount;
  final bool isDarkMode;

  DottedDesertMapPathPainter({
    required this.progress,
    required this.lessonCount,
    required this.isDarkMode,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (lessonCount == 0) return;

    final pathColors = isDarkMode
        ? [const Color(0xFFFFD700), const Color(0xFFFFE082)]
        : [const Color(0xFFFF8C42), const Color(0xFFFFB347)];

    final dotPaint = Paint()
      ..color = pathColors[0].withOpacity(0.8)
      ..style = PaintingStyle.fill;

    final glowPaint = Paint()
      ..color = pathColors[1].withOpacity(0.4)
      ..style = PaintingStyle.fill;

    final double centerX = size.width * 0.5;
    final double startY = size.height * 0.12;
    final double endY = size.height * 0.85;

    final List<Offset> pathPoints = [];

    for (int i = 0; i <= lessonCount + 1; i++) {
      final t = i / (lessonCount + 1);
      final amplitude = size.width * 0.15;
      final x = centerX + amplitude * math.sin(t * math.pi * 2.2);
      final y = startY + (endY - startY) * t;
      pathPoints.add(Offset(x, y));
    }

    for (int i = 0; i < pathPoints.length - 1; i++) {
      _drawDottedLine(canvas, pathPoints[i], pathPoints[i + 1], dotPaint, glowPaint);
    }

    if (progress > 0.3) {
      for (int i = 0; i < pathPoints.length; i++) {
        final sparkProgress = (progress * pathPoints.length - i).clamp(0.0, 1.0);
        if (sparkProgress > 0) {
          _drawSparkle(canvas, pathPoints[i], sparkProgress, pathColors[0]);
        }
      }
    }
  }

  void _drawDottedLine(Canvas canvas, Offset start, Offset end, Paint dotPaint, Paint glowPaint) {
    final distance = (end - start).distance;
    final dotSpacing = 12.0;
    final dotCount = (distance / dotSpacing).floor();

    for (int i = 0; i <= dotCount; i++) {
      final t = i / dotCount;
      final point = Offset.lerp(start, end, t)!;

      canvas.drawCircle(point, 8, glowPaint);
      canvas.drawCircle(point, 4, dotPaint);
    }
  }

  void _drawSparkle(Canvas canvas, Offset center, double progress, Color color) {
    final sparkPaint = Paint()
      ..color = color.withOpacity(progress * 0.8)
      ..style = PaintingStyle.fill;

    final size = 6 + progress * 4;
    canvas.drawCircle(center, size, sparkPaint);

    final linePaint = Paint()
      ..color = Colors.white.withOpacity(0.6)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    canvas.drawLine(
      Offset(center.dx - size, center.dy),
      Offset(center.dx + size, center.dy),
      linePaint,
    );
    canvas.drawLine(
      Offset(center.dx, center.dy - size),
      Offset(center.dx, center.dy + size),
      linePaint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

// EnhancedSandFooterPainter
class EnhancedSandFooterPainter extends CustomPainter {
  final bool isDarkMode;
  final double animationValue;
  final Color primaryColor; // Add missing parameter
  final Color surfaceColor; // Add missing parameter
  final Color backgroundColor; // Add missing parameter

  EnhancedSandFooterPainter({
    required this.isDarkMode,
    required this.animationValue,
    required this.primaryColor, // Make required
    required this.surfaceColor, // Make required
    required this.backgroundColor, // Make required
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: isDarkMode ? [
        const Color(0xFF2D1B16).withOpacity(0.8),
        const Color(0xFF1A0F0B).withOpacity(0.9),
      ] : [
        const Color(0xFFF5E6D3).withOpacity(0.7),
        const Color(0xFFE6D4C1).withOpacity(0.8),
      ],
    );

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    paint.shader = gradient.createShader(rect);

    final path = Path();
    path.moveTo(0, size.height * 0.2);

    for (double x = 0; x <= size.width; x += 10) {
      final y = size.height * 0.2 +
          math.sin((x / size.width * math.pi * 5) + (animationValue * math.pi * 2)) * 15 +
          math.sin((x / size.width * math.pi * 3) + (animationValue * math.pi * 1.5)) * 8 +
          math.sin((x / size.width * math.pi * 7) + (animationValue * math.pi * 0.8)) * 4;
      path.lineTo(x, y);
    }

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);

    final texturePaint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < 40; i++) {
      final x = (size.width * math.Random(i).nextDouble());
      final y = size.height * 0.3 + (size.height * 0.7 * math.Random(i + 50).nextDouble());
      final radius = 1 + math.Random(i + 100).nextDouble() * 3;

      texturePaint.color = (isDarkMode
          ? const Color(0xFF4A3429)
          : const Color(0xFFF0E4D2)).withOpacity(0.4);

      canvas.drawCircle(Offset(x, y), radius, texturePaint);
    }

    for (int i = 0; i < 80; i++) {
      final x = (size.width * math.Random(i + 200).nextDouble());
      final y = size.height * 0.25 + (size.height * 0.75 * math.Random(i + 300).nextDouble());
      final radius = 0.5 + math.Random(i + 400).nextDouble() * 1.5;

      texturePaint.color = (isDarkMode
          ? const Color(0xFF5D4037)
          : const Color(0xFFEAD7C3)).withOpacity(0.3);

      canvas.drawCircle(Offset(x, y), radius, texturePaint);
    }

    for (int i = 0; i < 3; i++) {
      final ripplePaint = Paint()
        ..color = (isDarkMode
            ? const Color(0xFF3E2A1F)
            : const Color(0xFFE0D0BD)).withOpacity(0.2)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;

      final y = size.height * (0.4 + i * 0.2) +
          math.sin(animationValue * math.pi * 2 + i) * 5;

      final ripplePath = Path();
      ripplePath.moveTo(0, y);

      for (double x = 0; x <= size.width; x += 20) {
        final rippleY = y + math.sin((x / size.width * math.pi * 8) +
            (animationValue * math.pi * 2)) * 3;
        ripplePath.lineTo(x, rippleY);
      }

      canvas.drawPath(ripplePath, ripplePaint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

// CircularProgressPainter
class CircularProgressPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;

  CircularProgressPainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final backgroundPaint = Paint()
      ..color = color.withOpacity(0.15)
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    final glowPaint = Paint()
      ..color = color.withOpacity(0.3)
      ..strokeWidth = strokeWidth + 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final progressPaint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * math.pi * progress;

    if (progress > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        sweepAngle,
        false,
        glowPaint,
      );
    }

    if (progress > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        sweepAngle,
        false,
        progressPaint,
      );
    }

    if (progress > 0.98) {
      final sparkPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;

      final endPoint = Offset(
        center.dx + radius * math.cos(sweepAngle - math.pi / 2),
        center.dy + radius * math.sin(sweepAngle - math.pi / 2),
      );

      canvas.drawCircle(endPoint, strokeWidth / 2, sparkPaint);

      final rayPaint = Paint()
        ..color = Colors.white.withOpacity(0.8)
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke;

      for (int i = 0; i < 4; i++) {
        final angle = (i * math.pi / 2) + sweepAngle - math.pi / 2;
        final rayStart = Offset(
          endPoint.dx + (strokeWidth / 2) * math.cos(angle),
          endPoint.dy + (strokeWidth / 2) * math.sin(angle),
        );
        final rayEnd = Offset(
          endPoint.dx + strokeWidth * 1.5 * math.cos(angle),
          endPoint.dy + strokeWidth * 1.5 * math.sin(angle),
        );

        canvas.drawLine(rayStart, rayEnd, rayPaint);
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}