// lib/features/community/presentation/widgets/community_search_bar.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:grad_project/core/theme/app_theme.dart';

class CommunitySearchBar extends StatelessWidget {
  final bool isDarkMode;
  final TextEditingController? controller;
  final Function(String)? onChanged;
  final VoidCallback? onTap;

  const CommunitySearchBar({
    Key? key,
    required this.isDarkMode,
    this.controller,
    this.onChanged,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        onTap: onTap,
        textAlign: TextAlign.right,
        style: TextStyle(
          color: isDarkMode
              ? Colors.white
              : const Color(0xFF2C2C2C),
          fontSize: 14.sp,
          fontFamily: 'Tajawal',
        ),
        decoration: InputDecoration(
          hintText: 'البحث في المجتمعات...',
          hintStyle: TextStyle(
            color: isDarkMode
                ? const Color(0xFF9E9E9E)
                : const Color(0xFF757575),
            fontSize: 14.sp,
            fontFamily: 'Tajawal',
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          suffixIcon: Padding(
            padding: EdgeInsets.only(right: 12.w),
            child: Icon(
              Icons.search,
              color: isDarkMode
                  ? const Color(0xFF9E9E9E)
                  : const Color(0xFF757575),
              size: 20.r,
            ),
          ),
          suffixIconConstraints: BoxConstraints(
            minWidth: 20.r,
            minHeight: 20.r,
          ),
        ),
      ),
    );
  }
}