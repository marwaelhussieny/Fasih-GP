// lib/features/community/presentation/widgets/community_card.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:grad_project/core/theme/app_theme.dart';

class CommunityCard extends StatefulWidget {
  final String name;
  final String description;
  final String members;
  final String image;
  final bool isDarkMode;
  final String? category;
  final bool? isJoined;

  const CommunityCard({
    Key? key,
    required this.name,
    required this.description,
    required this.members,
    required this.image,
    required this.isDarkMode,
    this.category,
    this.isJoined,
  }) : super(key: key);

  @override
  State<CommunityCard> createState() => _CommunityCardState();
}

class _CommunityCardState extends State<CommunityCard> {
  bool isJoined = false;

  @override
  void initState() {
    super.initState();
    isJoined = widget.isJoined ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Header with image and basic info
          _buildHeader(),
          SizedBox(height: 12.h),

          // Description
          _buildDescription(),
          SizedBox(height: 12.h),

          // Category and members info
          if (widget.category != null) _buildCategoryAndMembers(),
          SizedBox(height: 12.h),

          // Action button
          _buildActionButton(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                widget.name,
                style: TextStyle(
                  color: widget.isDarkMode
                      ? Colors.white
                      : const Color(0xFF2C2C2C),
                  fontWeight: FontWeight.bold,
                  fontSize: 16.sp,
                  fontFamily: 'Tajawal',
                ),
                textAlign: TextAlign.right,
              ),
              SizedBox(height: 3.h),
              Text(
                '${widget.members} عضو',
                style: TextStyle(
                  color: widget.isDarkMode
                      ? const Color(0xFF9E9E9E)
                      : const Color(0xFF757575),
                  fontSize: 12.sp,
                  fontFamily: 'Tajawal',
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.right,
              ),
            ],
          ),
        ),
        SizedBox(width: 12.w),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: const Color(0xFFFF7F50).withOpacity(0.3),
              width: 1.5.w,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10.r),
            child: Image.network(
              widget.image,
              width: 50.w,
              height: 50.h,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 50.w,
                  height: 50.h,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF7F50).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(
                    Icons.group,
                    color: const Color(0xFFFF7F50),
                    size: 24.r,
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDescription() {
    return Text(
      widget.description,
      textAlign: TextAlign.right,
      style: TextStyle(
        color: widget.isDarkMode
            ? Colors.white.withOpacity(0.8)
            : const Color(0xFF2C2C2C).withOpacity(0.8),
        fontSize: 13.sp,
        fontFamily: 'Tajawal',
        height: 1.5,
        letterSpacing: 0.2,
      ),
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildCategoryAndMembers() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (isJoined) ...[
          Container(
            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6.r),
              border: Border.all(
                color: Colors.green.withOpacity(0.3),
                width: 1.w,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'منضم',
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 10.sp,
                    fontFamily: 'Tajawal',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(width: 3.w),
                Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 10.r,
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
        ],
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: const Color(0xFFFF7F50).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(
              color: const Color(0xFFFF7F50).withOpacity(0.3),
              width: 1.w,
            ),
          ),
          child: Text(
            widget.category!,
            style: TextStyle(
              color: const Color(0xFFFF7F50),
              fontSize: 11.sp,
              fontFamily: 'Tajawal',
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton() {
    return SizedBox(
      width: double.infinity,
      child: Container(
        decoration: BoxDecoration(
          color: isJoined ? const Color(0xFF9E9E9E) : const Color(0xFFFF7F50),
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: (isJoined ? const Color(0xFF9E9E9E) : const Color(0xFFFF7F50))
                  .withOpacity(0.3),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: () {
            setState(() {
              isJoined = !isJoined;
            });
            // TODO: Implement join/leave community functionality
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            padding: EdgeInsets.symmetric(vertical: 12.h),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isJoined ? Icons.check_circle : Icons.add,
                color: Colors.white,
                size: 18.r,
              ),
              SizedBox(width: 6.w),
              Text(
                isJoined ? 'انضممت بالفعل' : 'انضمام للمجتمع',
                style: TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}