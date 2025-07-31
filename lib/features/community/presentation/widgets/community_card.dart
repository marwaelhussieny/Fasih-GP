// lib/features/community/presentation/widgets/community_card.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:grad_project/features/home/presentation/screens/home_screen.dart' show primaryOrange, desertSand, nightBlue, starGold, lightOrange, darkPurple, warmAmber;

class CommunityCard extends StatelessWidget {
  final String name;
  final String description;
  final String members;
  final String image;
  final bool isDarkMode;

  const CommunityCard({
    Key? key,
    required this.name,
    required this.description,
    required this.members,
    required this.image,
    required this.isDarkMode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDarkMode
              ? [darkPurple.withOpacity(0.8), nightBlue.withOpacity(0.6)]
              : [Colors.white, desertSand.withOpacity(0.3)],
        ),
        borderRadius: BorderRadius.circular(20.r),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end, // Align content to the right for Arabic
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end, // Align to right
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end, // Align text to right
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        color: isDarkMode ? Colors.white : primaryOrange,
                        fontWeight: FontWeight.bold,
                        fontSize: 18.sp,
                        fontFamily: 'Tajawal',
                      ),
                      textAlign: TextAlign.right,
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      '$members عضو', // [members] member
                      style: TextStyle(
                        color: isDarkMode ? Colors.white70 : Colors.grey.shade600,
                        fontSize: 13.sp,
                        fontFamily: 'Tajawal',
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ],
                ),
              ),
              SizedBox(width: 15.w),
              ClipRRect(
                borderRadius: BorderRadius.circular(12.r),
                child: Image.network(
                  image,
                  width: 60.w,
                  height: 60.h,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 60.w,
                      height: 60.h,
                      decoration: BoxDecoration(
                        color: isDarkMode ? darkPurple.withOpacity(0.5) : lightOrange.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Icon(
                        Icons.group,
                        color: isDarkMode ? starGold : primaryOrange,
                        size: 30.r,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 15.h),
          Text(
            description,
            textAlign: TextAlign.right,
            style: TextStyle(
              color: isDarkMode ? Colors.white70 : Colors.black87,
              fontSize: 14.sp,
              fontFamily: 'Tajawal',
              height: 1.5,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 15.h),
          Align(
            alignment: Alignment.centerLeft, // Align button to the left
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [primaryOrange, primaryOrange.withOpacity(0.8)],
                ),
                borderRadius: BorderRadius.circular(15.r),
                boxShadow: [
                  BoxShadow(
                    color: primaryOrange.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Navigate to community details screen
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.r),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned.fill(
                      child: Center(
                        child: Opacity(
                          opacity: 0.1, // Subtle opacity for background text
                          child: Text(
                            'عرض', // View
                            style: TextStyle(
                              fontFamily: 'Tajawal',
                              fontSize: 40.sp,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Text(
                      'عرض المجتمع', // View Community
                      style: TextStyle(
                        fontFamily: 'Tajawal',
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
