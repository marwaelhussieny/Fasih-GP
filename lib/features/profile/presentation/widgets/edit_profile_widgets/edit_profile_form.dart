// lib/features/profile/presentation/widgets/edit_profile_widgets/edit_profile_form.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
// FIX: Corrected import path for AppFormValidators
import 'package:grad_project/features/profile/presentation/utils/app_form_validators.dart';

class EditProfileForm extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController phoneController;
  final TextEditingController emailController;
  final TextEditingController dateOfBirthController;
  final TextEditingController jobController;
  final VoidCallback onDateOfBirthTap;

  const EditProfileForm({
    Key? key,
    required this.nameController,
    required this.phoneController,
    required this.emailController,
    required this.dateOfBirthController,
    required this.jobController,
    required this.onDateOfBirthTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color textColor = theme.textTheme.bodyLarge!.color!;
    final Color primaryColor = theme.primaryColor;

    // Helper to build themed text form fields
    Widget _buildTextFormField({
      required TextEditingController controller,
      required String labelText,
      required IconData prefixIcon,
      TextInputType keyboardType = TextInputType.text,
      String? Function(String?)? validator,
      bool readOnly = false,
      VoidCallback? onTap,
    }) {
      return TextFormField(
        controller: controller,
        textAlign: TextAlign.right, // Align text to the right for Arabic
        keyboardType: keyboardType,
        readOnly: readOnly,
        onTap: onTap,
        validator: validator,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: textColor,
          fontSize: 16.sp,
        ) ?? const TextStyle(), // Fallback
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: theme.inputDecorationTheme.labelStyle?.copyWith(
            fontSize: 16.sp,
            color: theme.hintColor, // Themed hint/label color
          ) ?? const TextStyle(),
          prefixIcon: Container(
            margin: EdgeInsets.all(8.r),
            padding: EdgeInsets.all(8.r),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(
              prefixIcon,
              color: primaryColor,
              size: 20.r,
            ),
          ),
          contentPadding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
          filled: true,
          fillColor: theme.cardColor, // Themed fill color
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16.r),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16.r),
            borderSide: BorderSide(
              color: theme.dividerColor.withOpacity(0.3), // Themed border color
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16.r),
            borderSide: BorderSide(
              color: theme.primaryColor, // Themed focused border color
              width: 2,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16.r),
            borderSide: BorderSide(
              color: theme.colorScheme.error, // Themed error border color
              width: 2,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16.r),
            borderSide: BorderSide(
              color: theme.colorScheme.error, // Themed focused error border color
              width: 2,
            ),
          ),
          errorStyle: theme.textTheme.bodySmall?.copyWith(
            fontSize: 12.sp,
            color: theme.colorScheme.error, // Themed error text style
          ) ?? const TextStyle(),
        ),
      );
    }

    return Column(
      children: [
        _buildTextFormField(
          controller: nameController,
          labelText: 'الاسم الكامل', // Full Name
          prefixIcon: Icons.person_outline,
          validator: AppFormValidators.validateName,
        ),
        SizedBox(height: 16.h),
        _buildTextFormField(
          controller: phoneController,
          labelText: 'رقم الهاتف', // Phone Number
          prefixIcon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
          validator: AppFormValidators.validatePhoneNumber,
        ),
        SizedBox(height: 16.h),
        _buildTextFormField(
          controller: emailController,
          labelText: 'البريد الإلكتروني', // Email
          prefixIcon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
          validator: AppFormValidators.validateEmail,
        ),
        SizedBox(height: 16.h),
        _buildTextFormField(
          controller: dateOfBirthController,
          labelText: 'تاريخ الميلاد', // Date of Birth
          prefixIcon: Icons.calendar_today_outlined,
          readOnly: true,
          onTap: onDateOfBirthTap,
          validator: AppFormValidators.validateDateOfBirth,
        ),
        SizedBox(height: 16.h),
        _buildTextFormField(
          controller: jobController,
          labelText: 'الوظيفة', // Job
          prefixIcon: Icons.work_outline,
          validator: AppFormValidators.validateJob,
        ),
      ],
    );
  }
}
