// lib/features/community/presentation/widgets/post_card.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:grad_project/core/theme/app_theme.dart';

class PostCard extends StatefulWidget {
  final String userName;
  final String communityName;
  final String userAvatar;
  final String postContent;
  final List<String> hashtags;
  final int likes;
  final int comments;
  final bool isDarkMode;
  final String? timeAgo;

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
    this.timeAgo,
  }) : super(key: key);

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool isLiked = false;
  int currentLikes = 0;

  @override
  void initState() {
    super.initState();
    currentLikes = widget.likes;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // User Info Header
          _buildUserHeader(),
          SizedBox(height: 12.h),

          // Post Content
          _buildPostContent(),
          SizedBox(height: 10.h),

          // Hashtags
          if (widget.hashtags.isNotEmpty) _buildHashtags(),
          SizedBox(height: 12.h),

          // Action Buttons
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildUserHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                widget.userName,
                style: TextStyle(
                  color: widget.isDarkMode
                      ? Colors.white
                      : const Color(0xFF2C2C2C),
                  fontWeight: FontWeight.bold,
                  fontSize: 14.sp,
                  fontFamily: 'Tajawal',
                ),
                textAlign: TextAlign.right,
              ),
              SizedBox(height: 2.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (widget.timeAgo != null) ...[
                    Text(
                      widget.timeAgo!,
                      style: TextStyle(
                        color: widget.isDarkMode
                            ? const Color(0xFF9E9E9E)
                            : const Color(0xFF757575),
                        fontSize: 11.sp,
                        fontFamily: 'Tajawal',
                      ),
                    ),
                    Text(
                      ' • ',
                      style: TextStyle(
                        color: widget.isDarkMode
                            ? const Color(0xFF9E9E9E)
                            : const Color(0xFF757575),
                        fontSize: 11.sp,
                      ),
                    ),
                  ],
                  Text(
                    'نشر في ${widget.communityName}',
                    style: TextStyle(
                      color: const Color(0xFFFF7F50),
                      fontSize: 11.sp,
                      fontFamily: 'Tajawal',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(width: 10.w),
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(0xFFFF7F50).withOpacity(0.3),
              width: 1.5.w,
            ),
          ),
          child: CircleAvatar(
            radius: 18.r,
            backgroundImage: NetworkImage(widget.userAvatar),
            backgroundColor: const Color(0xFFFF7F50).withOpacity(0.1),
            onBackgroundImageError: (exception, stackTrace) {
              // Handle image loading error
            },
            child: widget.userAvatar.isEmpty
                ? Icon(
              Icons.person,
              color: const Color(0xFFFF7F50),
              size: 20.r,
            )
                : null,
          ),
        ),
      ],
    );
  }

  Widget _buildPostContent() {
    return Text(
      widget.postContent,
      textAlign: TextAlign.right,
      style: TextStyle(
        color: widget.isDarkMode
            ? Colors.white
            : const Color(0xFF2C2C2C),
        fontSize: 14.sp,
        fontFamily: 'Tajawal',
        height: 1.5,
        letterSpacing: 0.2,
      ),
    );
  }

  Widget _buildHashtags() {
    return Container(
      width: double.infinity,
      child: Wrap(
        alignment: WrapAlignment.end,
        spacing: 6.w,
        runSpacing: 4.h,
        children: widget.hashtags.map((tag) => Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: const Color(0xFFFF7F50).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(
              color: const Color(0xFFFF7F50).withOpacity(0.3),
              width: 0.5.w,
            ),
          ),
          child: Text(
            tag,
            style: TextStyle(
              color: const Color(0xFFFF7F50),
              fontSize: 11.sp,
              fontFamily: 'Tajawal',
              fontWeight: FontWeight.w600,
            ),
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Share Button
        _buildActionButton(
          icon: Icons.share,
          label: 'نشر',
          color: widget.isDarkMode
              ? const Color(0xFF9E9E9E)
              : const Color(0xFF757575),
          onTap: () {
            // TODO: Implement share functionality
          },
        ),

        // Likes and Comments
        Row(
          children: [
            _buildActionButton(
              icon: Icons.chat_bubble_outline,
              label: '${widget.comments}',
              color: widget.isDarkMode
                  ? const Color(0xFF9E9E9E)
                  : const Color(0xFF757575),
              onTap: () {
                // TODO: Implement comments functionality
              },
            ),
            SizedBox(width: 12.w),
            _buildActionButton(
              icon: isLiked ? Icons.favorite : Icons.favorite_border,
              label: '$currentLikes',
              color: isLiked ? Colors.red : (widget.isDarkMode
                  ? const Color(0xFF9E9E9E)
                  : const Color(0xFF757575)),
              onTap: () {
                setState(() {
                  if (isLiked) {
                    currentLikes--;
                    isLiked = false;
                  } else {
                    currentLikes++;
                    isLiked = true;
                  }
                });
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: widget.isDarkMode
              ? const Color(0xFF404040).withOpacity(0.5)
              : const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1.w,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: color,
              size: 16.r,
            ),
            SizedBox(width: 4.w),
            Text(
              label,
              style: TextStyle(
                color: widget.isDarkMode
                    ? Colors.white
                    : const Color(0xFF2C2C2C),
                fontSize: 12.sp,
                fontFamily: 'Tajawal',
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}