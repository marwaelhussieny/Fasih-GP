// lib/features/auth/presentation/screens/forgot_password_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

// Import your authentication provider
import 'package:grad_project/features/auth/presentation/providers/auth_provider.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'يرجى إدخال البريد الإلكتروني';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'يرجى إدخال بريد إلكتروني صحيح';
    }
    return null;
  }

  // Handle password reset using AuthProvider
  Future<void> _handlePasswordReset() async {
    if (_formKey.currentState?.validate() ?? false) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      // Call the sendPasswordResetEmail method from the AuthProvider
      await authProvider.sendPasswordResetEmail(_emailController.text.trim());

      // Check the result from the AuthProvider
      if (authProvider.error == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'تم إرسال رابط إعادة التعيين إلى بريدك الإلكتروني',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Tajawal',
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
              backgroundColor: Theme.of(context).primaryColor,
            ),
          );
          // Navigate back to the previous screen (e.g., login screen)
          Navigator.pop(context);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                authProvider.error!, // Display error message from provider
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Tajawal',
                  color: Theme.of(context).colorScheme.onError,
                ),
              ),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final keyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;

    final ThemeData theme = Theme.of(context);
    final Color backgroundColor = theme.scaffoldBackgroundColor;
    final Color textColor = theme.textTheme.bodyLarge!.color!;
    final Color mutedTextColor = theme.hintColor;
    final Color primaryColor = theme.primaryColor;
    final Color secondaryColor = theme.colorScheme.secondary;
    final Color cardColor = theme.cardColor;

    // Listen to AuthProvider for loading state
    final authProvider = Provider.of<AuthProvider>(context);
    final bool isLoading = authProvider.isLoading;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 16.h),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Back Arrow
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    icon: Icon(
                      Icons.arrow_back_ios_new,
                      color: textColor,
                      size: 20.r,
                    ),
                    onPressed: () => Navigator.pop(context),
                    style: IconButton.styleFrom(
                      backgroundColor: cardColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      padding: EdgeInsets.all(12.r),
                    ),
                  ),
                ),
                SizedBox(height: 16.h),

                // Title
                Center(
                  child: Text(
                    'نسيت كلمة المرور',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: textColor,
                      fontSize: 28.sp,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
                SizedBox(height: 8.h),

                // Subtitle
                Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Text(
                      'أدخل بريدك الإلكتروني لإرسال رابط إعادة تعيين كلمة المرور',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: mutedTextColor,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w400,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                SizedBox(height: keyboardVisible ? 16.h : 32.h),

                // Image - Full width sizing (hidden when keyboard is visible)
                if (!keyboardVisible)
                  Container(
                    height: screenHeight * 0.35,
                    width: double.infinity,
                    margin: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Image.asset(
                      'assets/images/Reset_password.png',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: screenHeight * 0.35,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                          child: Icon(
                            Icons.lock_reset_outlined,
                            size: 80.r,
                            color: secondaryColor,
                          ),
                        );
                      },
                    ),
                  ),
                SizedBox(height: keyboardVisible ? 24.h : 40.h),

                // Email Input Field
                TextFormField(
                  controller: _emailController,
                  textAlign: TextAlign.right,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _handlePasswordReset(),
                  validator: _validateEmail,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: textColor,
                    fontSize: 16.sp,
                  ),
                  decoration: InputDecoration(
                    prefixIcon: Container(
                      margin: EdgeInsets.all(8.r),
                      padding: EdgeInsets.all(8.r),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Icon(
                        Icons.email_outlined,
                        color: primaryColor,
                        size: 20.r,
                      ),
                    ),
                    hintText: 'البريد الإلكتروني',
                    hintStyle: theme.inputDecorationTheme.hintStyle?.copyWith(
                      fontSize: 16.sp,
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 16.h,
                    ),
                    filled: true,
                    fillColor: theme.inputDecorationTheme.fillColor,
                    border: theme.inputDecorationTheme.border,
                    enabledBorder: theme.inputDecorationTheme.enabledBorder,
                    focusedBorder: theme.inputDecorationTheme.focusedBorder,
                    errorBorder: theme.inputDecorationTheme.errorBorder,
                    focusedErrorBorder: theme.inputDecorationTheme.focusedErrorBorder,
                    errorStyle: theme.inputDecorationTheme.errorStyle,
                  ),
                ),
                SizedBox(height: 32.h),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 56.h,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _handlePasswordReset,
                    style: theme.elevatedButtonTheme.style?.copyWith(
                      backgroundColor: MaterialStateProperty.resolveWith<Color?>(
                            (Set<MaterialState> states) {
                          if (states.contains(MaterialState.disabled)) {
                            return primaryColor.withOpacity(0.6);
                          }
                          return theme.elevatedButtonTheme.style?.backgroundColor?.resolve(states);
                        },
                      ),
                      foregroundColor: MaterialStateProperty.resolveWith<Color?>(
                            (Set<MaterialState> states) {
                          return theme.elevatedButtonTheme.style?.foregroundColor?.resolve(states);
                        },
                      ),
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.r),
                      )),
                      minimumSize: MaterialStateProperty.all(Size(double.infinity, 56.h)),
                    ),
                    child: isLoading
                        ? SizedBox(
                      height: 20.r,
                      width: 20.r,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.onPrimary),
                      ),
                    )
                        : Text(
                      'إرسال رابط إعادة التعيين',
                      style: theme.elevatedButtonTheme.style?.textStyle?.resolve({})?.copyWith(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 24.h),

                // Back to login link
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'العودة إلى تسجيل الدخول',
                      style: theme.textButtonTheme.style?.textStyle?.resolve({})?.copyWith(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: secondaryColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}