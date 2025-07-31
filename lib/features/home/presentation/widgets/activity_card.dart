// lib/features/home/presentation/widgets/activity_card.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:grad_project/features/home/domain/entities/lesson_activity_entity.dart';
import 'package:grad_project/features/home/presentation/screens/home_screen.dart'; // Import colors

class ActivityCard extends StatelessWidget {
  final LessonActivityEntity activity;
  final bool isUnlocked;
  final String lessonId;
  final bool isDarkMode;
  final Function(BuildContext context, LessonActivityEntity activity, String lessonId) handleActivityTap;

  const ActivityCard({
    Key? key,
    required this.activity,
    required this.isUnlocked,
    required this.lessonId,
    required this.isDarkMode,
    required this.handleActivityTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    IconData icon;
    List<Color> gradient;

    switch (activity.type) {
      case LessonActivityType.quiz:
        icon = Icons.quiz_rounded;
        gradient = isDarkMode
            ? [const Color(0xFF4A148C), const Color(0xFF6A1B9A)]
            : [const Color(0xFF9C27B0), const Color(0xFFBA68C8)];
        break;
      case LessonActivityType.writing:
        icon = Icons.edit_rounded;
        gradient = isDarkMode
            ? [const Color(0xFF0D47A1), const Color(0xFF1565C0)]
            : [const Color(0xFF2196F3), const Color(0xFF64B5F6)];
        break;
      case LessonActivityType.speaking:
        icon = Icons.mic_rounded;
        gradient = isDarkMode
            ? [const Color(0xFFAD1457), const Color(0xFFC2185B)]
            : [const Color(0xFFE91E63), const Color(0xFFF06292)];
        break;
      case LessonActivityType.flashcards:
        icon = Icons.layers_rounded;
        gradient = isDarkMode
            ? [const Color(0xFF2E7D32), const Color(0xFF388E3C)]
            : [const Color(0xFF4CAF50), const Color(0xFF81C784)];
        break;
      case LessonActivityType.grammar:
        icon = Icons.menu_book_rounded;
        gradient = isDarkMode
            ? [starGold, const Color(0xFFFFE082)]
            : [primaryOrange, lightOrange];
        break;
      default:
        icon = Icons.help_rounded;
        gradient = [Colors.grey.shade500, Colors.grey.shade600];
        break;
    }

    return GestureDetector(
      onTap: isUnlocked ? () => handleActivityTap(context, activity, lessonId) : null,
      child: Container(
        decoration: BoxDecoration(
          gradient: isUnlocked
              ? LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: activity.isCompleted
                ? [const Color(0xFF4CAF50), const Color(0xFF66BB6A)]
                : gradient,
          )
              : LinearGradient(
            colors: [Colors.grey.shade400, Colors.grey.shade500],
          ),
          borderRadius: BorderRadius.circular(24.r),
          boxShadow: [
            BoxShadow(
              color: isUnlocked
                  ? (activity.isCompleted ? Colors.green : gradient[0]).withOpacity(0.4)
                  : Colors.grey.withOpacity(0.3),
              spreadRadius: 0,
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              activity.isCompleted ? Icons.check_circle_rounded : icon,
              color: Colors.white,
              size: 40.r,
            ),
            SizedBox(height: 16.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.w),
              child: Text(
                activity.title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
