// lib/features/profile/presentation/widgets/stats_card.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:grad_project/features/profile/domain/entities/user_progress_entity.dart';

class StatsCard extends StatelessWidget {
  final UserProgressEntity? userProgress;

  const StatsCard({
    Key? key,
    required this.userProgress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            spreadRadius: 0,
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          SizedBox(height: 20.h),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  value: '${userProgress?.currentStreak ?? 0}',
                  label: 'أيام متتالية',
                  icon: Icons.local_fire_department_outlined,
                  color: Colors.red.shade500,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  value: '${userProgress?.totalLessonsCompleted ?? 0}',
                  label: 'دروس مكتملة',
                  icon: Icons.menu_book_outlined,
                  color: Colors.green.shade500,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  value: '${userProgress?.totalPoints ?? 0}',
                  label: 'نقاط الخبرة',
                  icon: Icons.star_outline,
                  color: Colors.amber.shade600,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  value: '${userProgress?.totalCorrectAnswers ?? 0}',
                  label: 'إجابات صحيحة',
                  icon: Icons.check_circle_outline,
                  color: Colors.blue.shade500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Icon(
          Icons.bar_chart_outlined,
          color: const Color(0xFFE67E22),
          size: 24.r,
        ),
        SizedBox(width: 8.w),
        Text(
          'إحصائياتك',
          style: TextStyle(
            fontFamily: 'Tajawal',
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: Colors.grey.shade800,
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem({
    required String value,
    required String label,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(16.w),
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28.r),
          SizedBox(height: 8.h),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 20.sp,
              fontWeight: FontWeight.w700,
              color: Colors.grey.shade800,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 12.sp,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}