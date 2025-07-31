// lib/features/profile/presentation/widgets/daily_achievements_card.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:grad_project/features/profile/presentation/providers/activity_provider.dart';

class DailyAchievementsCard extends StatelessWidget {
  final DateTime? selectedDay;

  const DailyAchievementsCard({
    Key? key,
    required this.selectedDay,
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
          _buildAchievementsList(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Icon(
          Icons.emoji_events_outlined,
          color: const Color(0xFFE67E22),
          size: 24.r,
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            'إنجازات اليوم (${DateFormat('d MMMM', 'ar').format(selectedDay ?? DateTime.now())})',
            style: TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: Colors.grey.shade800,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAchievementsList() {
    return Consumer<ActivityProvider>(
      builder: (context, activityProvider, child) {
        if (activityProvider.isLoadingAchievements) {
          return _buildLoadingState();
        }

        if (activityProvider.error != null) {
          return _buildErrorState();
        }

        // Convert Map<String, int> to List<String> for achievements
        // If the map contains achievement descriptions as keys, use those
        // Otherwise, create formatted strings from the key-value pairs
        final List<String> achievements = activityProvider.dailyAchievements.entries
            .map((entry) => entry.key.contains(':') || entry.key.contains('أ')
            ? entry.key // If it's already a description in Arabic
            : '${entry.key}: ${entry.value} نقطة') // Otherwise format it
            .toList();

        if (achievements.isEmpty) {
          return _buildEmptyState();
        }

        return _buildAchievementsContent(achievements);
      },
    );
  }

  Widget _buildLoadingState() {
    return SizedBox(
      height: 100.h,
      child: const Center(
        child: CircularProgressIndicator(
          color: Color(0xFFE67E22),
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return SizedBox(
      height: 100.h,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 32.r,
              color: Colors.red.shade400,
            ),
            SizedBox(height: 8.h),
            Text(
              'خطأ في تحميل الإنجازات',
              style: TextStyle(
                fontFamily: 'Tajawal',
                fontSize: 14.sp,
                color: Colors.red.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 40.h),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.sentiment_neutral_outlined,
            size: 48.r,
            color: Colors.grey.shade400,
          ),
          SizedBox(height: 12.h),
          Text(
            'لا توجد إنجازات لهذا اليوم',
            style: TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'ابدأ التعلم اليوم لتحقيق إنجازات جديدة!',
            style: TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 14.sp,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementsContent(List<String> achievements) {
    return Column(
      children: achievements.asMap().entries.map((entry) {
        final int index = entry.key;
        final String achievement = entry.value;

        return Container(
          margin: EdgeInsets.only(bottom: 12.h),
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFFE67E22).withOpacity(0.1),
                const Color(0xFFD35400).withOpacity(0.05),
              ],
              begin: Alignment.centerRight,
              end: Alignment.centerLeft,
            ),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: const Color(0xFFE67E22).withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              _buildAchievementIcon(),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildAchievementText(index, achievement),
              ),
              Icon(
                Icons.check_circle,
                color: Colors.green.shade500,
                size: 24.r,
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAchievementIcon() {
    return Container(
      width: 40.w,
      height: 40.w,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE67E22), Color(0xFFD35400)],
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE67E22).withOpacity(0.3),
            spreadRadius: 0,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(
        Icons.emoji_events,
        color: Colors.white,
        size: 20.r,
      ),
    );
  }

  Widget _buildAchievementText(int index, String achievement) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'إنجاز ${index + 1}',
          style: TextStyle(
            fontFamily: 'Tajawal',
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
            color: const Color(0xFFE67E22),
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          achievement,
          style: TextStyle(
            fontFamily: 'Tajawal',
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade800,
          ),
        ),
      ],
    );
  }
}