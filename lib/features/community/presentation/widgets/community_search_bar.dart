// lib/features/community/presentation/widgets/community_search_bar.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:grad_project/features/home/presentation/screens/home_screen.dart' show primaryOrange, desertSand, nightBlue, starGold, lightOrange, darkPurple;

class CommunitySearchBar extends StatelessWidget {
  final bool isDarkMode;

  const CommunitySearchBar({Key? key, required this.isDarkMode}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? darkPurple.withOpacity(0.7) : Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: (isDarkMode ? Colors.black : Colors.grey).withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(
          color: isDarkMode ? starGold.withOpacity(0.2) : primaryOrange.withOpacity(0.2),
          width: 1.w,
        ),
      ),
      child: TextField(
        textAlign: TextAlign.right,
        style: TextStyle(
          color: isDarkMode ? Colors.white : Colors.black87,
          fontSize: 16.sp,
          fontFamily: 'Tajawal',
        ),
        decoration: InputDecoration(
          hintText: 'البحث...', // Search...
          hintStyle: TextStyle(
            color: isDarkMode ? Colors.white54 : Colors.grey.shade600,
            fontSize: 16.sp,
            fontFamily: 'Tajawal',
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
          suffixIcon: Icon(
            Icons.search,
            color: isDarkMode ? starGold : primaryOrange,
            size: 24.r,
          ),
        ),
      ),
    );
  }
}
