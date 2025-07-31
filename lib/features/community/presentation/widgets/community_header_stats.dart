// lib/features/community/presentation/widgets/community_header_stats.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
// Ensure all necessary colors are imported
import 'package:grad_project/features/home/presentation/screens/home_screen.dart' show primaryOrange, desertSand, nightBlue, starGold, lightOrange, darkPurple, warmAmber, moonSilver;

class CommunityHeaderStats extends StatelessWidget {
  final bool isDarkMode;

  const CommunityHeaderStats({Key? key, required this.isDarkMode}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDarkMode
              ? [darkPurple.withOpacity(0.8), nightBlue.withOpacity(0.6)]
              : [Colors.white, desertSand.withOpacity(0.3)],
        ),
        borderRadius: BorderRadius.circular(25.r),
        border: Border.all(
          color: isDarkMode ? starGold.withOpacity(0.3) : primaryOrange.withOpacity(0.3),
          width: 1.5.w,
        ),
        boxShadow: [
          BoxShadow(
            color: (isDarkMode ? Colors.black : Colors.grey).withOpacity(0.15),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            icon: Icons.check_circle_outline_rounded,
            value: '226',
            color: isDarkMode ? starGold : primaryOrange,
            isDarkMode: isDarkMode,
          ),
          _buildStatItem(
            icon: Icons.local_fire_department_outlined,
            value: '3',
            color: isDarkMode ? lightOrange : primaryOrange,
            isDarkMode: isDarkMode,
          ),
          _buildStatItem(
            icon: Icons.flash_on_rounded,
            value: '2,542',
            color: isDarkMode ? warmAmber : lightOrange,
            isDarkMode: isDarkMode,
          ),
          _buildStatItem(
            icon: Icons.bar_chart_rounded,
            value: '', // No value in the image for this icon
            color: isDarkMode ? moonSilver : primaryOrange,
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
      children: [
        Icon(
          icon,
          color: color,
          size: 24.r,
        ),
        SizedBox(width: 8.w),
        Text(
          value,
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black87,
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            fontFamily: 'Tajawal',
          ),
        ),
      ],
    );
  }
}
