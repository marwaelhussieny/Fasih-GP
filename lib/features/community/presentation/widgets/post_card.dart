// lib/features/community/presentation/widgets/post_card.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
// Ensure all necessary colors are imported
import 'package:grad_project/features/home/presentation/screens/home_screen.dart' show primaryOrange, desertSand, nightBlue, starGold, lightOrange, darkPurple, warmAmber, moonSilver;

class PostCard extends StatelessWidget {
  final String userName;
  final String communityName;
  final String userAvatar;
  final String postContent;
  final List<String> hashtags;
  final int likes;
  final int comments;
  final bool isDarkMode;

  const PostCard({
    Key? key,
    required this.userName,
    required this.communityName,
    required this.userAvatar,
    required this.postContent,
    required this.hashtags,
    required this.likes,
    required this.comments,
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
          // User Info and Community
          Row(
            mainAxisAlignment: MainAxisAlignment.end, // Align to right
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.end, // Align text to right
                children: [
                  Text(
                    userName,
                    style: TextStyle(
                      color: isDarkMode ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.bold,
                      fontSize: 16.sp,
                      fontFamily: 'Tajawal',
                    ),
                  ),
                  Text(
                    'نشر في $communityName', // Posted in [Community Name]
                    style: TextStyle(
                      color: isDarkMode ? Colors.white70 : Colors.grey.shade600,
                      fontSize: 12.sp,
                      fontFamily: 'Tajawal',
                    ),
                  ),
                ],
              ),
              SizedBox(width: 12.w),
              CircleAvatar(
                radius: 20.r,
                backgroundImage: NetworkImage(userAvatar),
                backgroundColor: isDarkMode ? starGold.withOpacity(0.3) : primaryOrange.withOpacity(0.3),
              ),
            ],
          ),
          SizedBox(height: 15.h),

          // Post Content
          Text(
            postContent,
            textAlign: TextAlign.right,
            style: TextStyle(
              color: isDarkMode ? Colors.white70 : Colors.black87,
              fontSize: 15.sp,
              fontFamily: 'Tajawal',
              height: 1.5,
            ),
          ),
          SizedBox(height: 10.h),

          // Hashtags
          Wrap(
            alignment: WrapAlignment.end, // Align hashtags to the right
            spacing: 8.w,
            runSpacing: 4.h,
            children: hashtags.map((tag) => Text(
              tag,
              style: TextStyle(
                color: isDarkMode ? lightOrange : primaryOrange,
                fontSize: 13.sp,
                fontFamily: 'Tajawal',
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.right,
            )).toList(),
          ),
          SizedBox(height: 15.h),

          // Actions (Likes, Comments, Share)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween, // Distribute space
            children: [
              // Share Button
              _buildActionButton(
                icon: Icons.share_rounded,
                label: 'نشر', // Share
                count: null,
                color: isDarkMode ? warmAmber : primaryOrange,
                isDarkMode: isDarkMode,
                onTap: () {
                  // TODO: Implement share functionality
                },
              ),
              // Likes and Comments
              Row(
                children: [
                  _buildActionButton(
                    icon: Icons.comment_rounded,
                    label: comments.toString(),
                    color: isDarkMode ? moonSilver : Colors.grey,
                    isDarkMode: isDarkMode,
                    onTap: () {
                      // TODO: Implement view comments functionality
                    },
                  ),
                  SizedBox(width: 15.w),
                  _buildActionButton(
                    icon: Icons.favorite_rounded,
                    label: likes.toString(),
                    color: isDarkMode ? Colors.redAccent : Colors.red,
                    isDarkMode: isDarkMode,
                    onTap: () {
                      // TODO: Implement like functionality
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String? label,
    required Color color,
    required bool isDarkMode,
    required VoidCallback onTap,
    int? count, // Optional count for likes/comments
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isDarkMode ? darkPurple.withOpacity(0.5) : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(15.r),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1.w,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: color,
              size: 18.r,
            ),
            if (label != null) ...[
              SizedBox(width: 8.w),
              Text(
                label,
                style: TextStyle(
                  color: isDarkMode ? Colors.white70 : Colors.black87,
                  fontSize: 13.sp,
                  fontFamily: 'Tajawal',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
