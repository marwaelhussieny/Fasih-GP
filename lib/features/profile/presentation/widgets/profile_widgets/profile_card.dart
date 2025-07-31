// lib/features/profile/presentation/widgets/profile_widgets/profile_card.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:grad_project/features/profile/domain/entities/user_entity.dart';
import 'package:grad_project/core/navigation/app_routes.dart'; // For navigation

class ProfileCard extends StatelessWidget {
  final UserEntity user;

  const ProfileCard({
    Key? key,
    required this.user,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color textColor = theme.textTheme.bodyLarge!.color!;
    final Color mutedTextColor = theme.hintColor;
    final Color primaryColor = theme.primaryColor;
    final Color cardColor = theme.cardColor;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
      decoration: BoxDecoration(
        color: cardColor, // Themed card background
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.08), // Themed shadow
            spreadRadius: 0,
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              // Navigates to EditProfileScreen when image is tapped
              Navigator.pushNamed(context, AppRoutes.editProfile);
            },
            child: CircleAvatar(
              radius: 50.r, // Responsive size
              backgroundColor: primaryColor.withOpacity(0.1), // Subtle background
              backgroundImage: user.profileImageUrl != null && user.profileImageUrl!.isNotEmpty
                  ? NetworkImage(user.profileImageUrl!)
                  : null,
              child: user.profileImageUrl == null || user.profileImageUrl!.isEmpty
                  ? Icon(Icons.person, size: 50.r, color: primaryColor) // Themed icon
                  : null,
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            user.name,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: textColor,
              fontWeight: FontWeight.w700,
              fontSize: 22.sp, // Responsive font size
            ) ?? const TextStyle(), // Fallback
          ),
          SizedBox(height: 4.h),
          Text(
            user.email,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: mutedTextColor,
              fontSize: 14.sp, // Responsive font size
            ) ?? const TextStyle(), // Fallback
          ),
          SizedBox(height: 20.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // Navigates to EditProfileScreen when button is pressed
                Navigator.pushNamed(context, AppRoutes.editProfile);
              },
              style: theme.elevatedButtonTheme.style?.copyWith(
                minimumSize: MaterialStateProperty.all(Size(double.infinity, 48.h)), // Responsive height
                padding: MaterialStateProperty.all(EdgeInsets.symmetric(vertical: 12.h)),
              ),
              child: Text(
                'تعديل الحساب الشخصي', // Edit Personal Account
                style: theme.elevatedButtonTheme.style?.textStyle?.resolve({})?.copyWith(
                  fontSize: 16.sp, // Responsive font size
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}