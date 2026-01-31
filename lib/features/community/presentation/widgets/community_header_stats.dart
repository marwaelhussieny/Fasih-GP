// lib/features/community/presentation/widgets/community_header_stats.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:grad_project/core/theme/app_theme.dart';

class CommunityHeaderStats extends StatelessWidget {
  final bool isDarkMode;

  const CommunityHeaderStats({Key? key, required this.isDarkMode}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: isDarkMode
            ? const Color(0xFF2A2A2A)
            : Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: isDarkMode
              ? const Color(0xFF404040)
              : const Color(0xFFE0E0E0),
          width: 1.w,
        ),
        boxShadow: [
          BoxShadow(
            color: isDarkMode
                ? Colors.black.withOpacity(0.2)
                : Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatItem(
            icon: Icons.check_circle,
            value: '226',
            color: const Color(0xFF4CAF50),
            isDarkMode: isDarkMode,
          ),
          _buildDivider(),
          _buildStatItem(
            icon: Icons.local_fire_department,
            value: '3',
            color: const Color(0xFFFF9800),
            isDarkMode: isDarkMode,
          ),
          _buildDivider(),
          _buildStatItem(
            icon: Icons.flash_on,
            value: '2,542',
            color: const Color(0xFFFFC107),
            isDarkMode: isDarkMode,
          ),
          _buildDivider(),
          _buildStatItem(
            icon: Icons.bar_chart,
            value: '',
            color: isDarkMode ? const Color(0xFF9E9E9E) : const Color(0xFF757575),
            isDarkMode: isDarkMode,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required Color color,
    required bool isDarkMode,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: color,
          size: 18.r,
        ),
        if (value.isNotEmpty) ...[
          SizedBox(width: 4.w),
          Text(
            value,
            style: TextStyle(
              color: isDarkMode
                  ? Colors.white
                  : const Color(0xFF2C2C2C),
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              fontFamily: 'Tajawal',
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 16.h,
      width: 1.w,
      color: isDarkMode
          ? const Color(0xFF404040)
          : const Color(0xFFE0E0E0),
    );
  }
}