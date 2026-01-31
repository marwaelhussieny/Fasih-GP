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
    final ThemeData theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.5)
                : Colors.black.withOpacity(0.08),
            spreadRadius: 0,
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(theme),
          SizedBox(height: 20.h),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  context: context,
                  value: '${userProgress?.easyCount ?? 0}',
                  label: 'أيام متتالية',
                  icon: Icons.local_fire_department_outlined,
                  color: Colors.red.shade500,
                  bgColor: isDark
                      ? Colors.red.shade900.withOpacity(0.15)
                      : Colors.red.shade50,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  context: context,
                  value: '${userProgress?.totalWords ?? 0}',
                  label: 'دروس مكتملة',
                  icon: Icons.menu_book_outlined,
                  color: Colors.green.shade500,
                  bgColor: isDark
                      ? Colors.green.shade900.withOpacity(0.15)
                      : Colors.green.shade50,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  context: context,
                  value: '${userProgress?.hardCount ?? 0}',
                  label: 'نقاط الخبرة',
                  icon: Icons.star_outline,
                  color: Colors.amber.shade600,
                  bgColor: isDark
                      ? Colors.amber.shade700.withOpacity(0.15)
                      : Colors.amber.shade50,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  context: context,
                  value: '${userProgress?.mediumCount ?? 0}',
                  label: 'إجابات صحيحة',
                  icon: Icons.check_circle_outline,
                  color: Colors.blue.shade500,
                  bgColor: isDark
                      ? Colors.blue.shade900.withOpacity(0.15)
                      : Colors.blue.shade50,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Row(
      children: [
        Icon(
          Icons.bar_chart_outlined,
          color: theme.primaryColor,
          size: 24.r,
        ),
        SizedBox(width: 8.w),
        Text(
          'إحصائياتك',
          style: theme.textTheme.titleMedium?.copyWith(
            fontFamily: 'Tajawal',
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem({
    required BuildContext context,
    required String value,
    required String label,
    required IconData icon,
    required Color color,
    required Color bgColor,
  }) {
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.white;

    return Container(
      padding: EdgeInsets.all(16.w),
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      decoration: BoxDecoration(
        color: bgColor,
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
              color: textColor,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 12.sp,
              color: textColor.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}