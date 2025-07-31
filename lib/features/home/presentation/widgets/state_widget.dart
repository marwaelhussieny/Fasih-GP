// lib/features/home/presentation/widgets/state_widgets.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:grad_project/features/home/presentation/screens/home_screen.dart'; // Import colors

class LoadingState extends StatelessWidget {
  final bool isDarkMode;

  const LoadingState({Key? key, required this.isDarkMode}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120.r,
            height: 120.r,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDarkMode
                    ? [starGold, const Color(0xFFFFE082)]
                    : [primaryOrange, lightOrange],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: (isDarkMode ? starGold : primaryOrange).withOpacity(0.4),
                  blurRadius: 30,
                  offset: const Offset(0, 15),
                ),
              ],
            ),
            child: Center(
              child: CircularProgressIndicator(
                color: isDarkMode ? nightBlue : Colors.white,
                strokeWidth: 5.w,
              ),
            ),
          ),
          SizedBox(height: 40.h),
          Text(
            'جاري تحميل مسار التعلم...',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 20.sp,
              shadows: [
                Shadow(
                  offset: const Offset(0, 2),
                  blurRadius: 4,
                  color: (isDarkMode ? nightBlue : primaryOrange).withOpacity(0.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ErrorState extends StatelessWidget {
  final bool isDarkMode;
  final String? error;
  final VoidCallback onRetry;

  const ErrorState({
    Key? key,
    required this.isDarkMode,
    this.error,
    required this.onRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(40.r),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.red.shade100,
                    Colors.red.shade50,
                  ],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withOpacity(0.3),
                    spreadRadius: 0,
                    blurRadius: 25,
                    offset: const Offset(0, 15),
                  ),
                ],
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 90.r,
                color: Colors.red.shade600,
              ),
            ),
            SizedBox(height: 40.h),
            Text(
              'خطأ في تحميل الدروس',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 26.sp,
                shadows: [
                  Shadow(
                    offset: const Offset(0, 2),
                    blurRadius: 4,
                    color: (isDarkMode ? nightBlue : primaryOrange).withOpacity(0.5),
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16.h),
            Text(
              error ?? 'حدث خطأ غير متوقع',
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 18.sp,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 40.h),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.white, Colors.white.withOpacity(0.95)],
                ),
                borderRadius: BorderRadius.circular(30.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: onRetry,
                icon: Icon(Icons.refresh_rounded, color: isDarkMode ? nightBlue : primaryOrange, size: 28.r),
                label: Text(
                  'إعادة المحاولة',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? nightBlue : primaryOrange,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 20.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.r),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  final bool isDarkMode;

  const EmptyState({Key? key, required this.isDarkMode}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(50.r),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white,
                  Colors.white.withOpacity(0.9),
                ],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: (isDarkMode ? nightBlue : primaryOrange).withOpacity(0.2),
                  spreadRadius: 0,
                  blurRadius: 40,
                  offset: const Offset(0, 20),
                ),
              ],
            ),
            child: Icon(
              Icons.school_rounded,
              size: 120.r,
              color: isDarkMode ? nightBlue : primaryOrange,
            ),
          ),
          SizedBox(height: 50.h),
          Text(
            'لا توجد دروس متاحة',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 30.sp,
              shadows: [
                Shadow(
                  offset: const Offset(0, 2),
                  blurRadius: 4,
                  color: (isDarkMode ? nightBlue : primaryOrange).withOpacity(0.5),
                ),
              ],
            ),
          ),
          SizedBox(height: 20.h),
          Text(
            'سيتم إضافة دروس جديدة قريباً',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 20.sp,
            ),
          ),
        ],
      ),
    );
  }
}
