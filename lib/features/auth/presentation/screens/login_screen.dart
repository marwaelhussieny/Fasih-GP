// lib/features/auth/presentation/screens/login_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

// Import your authentication provider
import 'package:grad_project/features/auth/presentation/providers/auth_provider.dart';

// Import your app routes for navigation
import 'package:grad_project/core/navigation/app_routes.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
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

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'يرجى إدخال كلمة المرور';
    }
    if (value.length < 6) {
      return 'يجب أن تكون كلمة المرور 6 أحرف على الأقل';
    }
    return null;
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final loginEmail = _emailController.text.trim().toLowerCase();
    final loginPassword = _passwordController.text.trim().toLowerCase();
    print('🔐 Login Screen: Starting login for $loginEmail');

    try {
      await authProvider.login(
        // BuildContext : context,
        email: loginEmail,
        password: _passwordController.text,
      );

      // // if (!mounted) return;
      // if (context.mounted) {
      //   Navigator.pushReplacementNamed(context, AppRoutes.main);
      //   // or using GoRouter:
      //   // GoRouter.of(context).go(AppRoutes.home);
      // }
      if (authProvider.currentUser != null) {
        final user = authProvider.currentUser!;
        print('🔐 Login successful for user: ${user.email} (verified: ${user.isVerified})');

        // The AuthGuard will handle this navigation. The logic below is still valid
        // but the GoRouter redirect will likely be triggered first.
        if (user.isVerified) {
          print('🔐 User verified, navigating to home');
          Navigator.pushReplacementNamed(context, AppRoutes.main);
        } else {
          print('🔐 User needs OTP, navigating to OTP screen');
          Navigator.pushReplacementNamed(
            context,
            AppRoutes.otp,
            arguments: {'email': user.email},
          );
        }
      } else {
        print('🔐 Login failed or user data not found. Error: ${authProvider.error}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              authProvider.error ?? 'حدث خطأ غير متوقع. يرجى المحاولة مرة أخرى.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Tajawal',
                color: Theme.of(context).colorScheme.onError,
              ),
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      print('🔐 Login exception: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'حدث خطأ غير متوقع. يرجى المحاولة مرة أخرى.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Tajawal',
                color: Theme.of(context).colorScheme.onError,
              ),
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color backgroundColor = theme.scaffoldBackgroundColor;
    final Color textColor = theme.textTheme.bodyLarge!.color!;
    final Color mutedTextColor = theme.hintColor;
    final Color primaryColor = theme.primaryColor;

    final authProvider = Provider.of<AuthProvider>(context);
    final bool isLoading = authProvider.isLoading;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 32.w),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 24.h),
                Center(
                  child: Text(
                    'تسجيل الدخول',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: textColor,
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                SizedBox(height: 8.h),
                Center(
                  child: Text(
                    'يرجى إدخال البيانات لاستخدام حسابك',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: mutedTextColor,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w400,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: 32.h),
                SizedBox(
                  height: 250.h,
                  child: Image.asset(
                    'assets/images/login_logo.png',
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 250.h,
                        color: theme.cardColor,
                        child: Center(
                          child: Icon(Icons.person_outline, size: 100.r, color: mutedTextColor),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: 32.h),
                TextFormField(
                  controller: _emailController,
                  textAlign: TextAlign.right,
                  keyboardType: TextInputType.emailAddress,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: textColor,
                    fontSize: 14.sp,
                  ),
                  decoration: InputDecoration(
                    prefixIcon: Icon(
                      Icons.email_outlined,
                      color: primaryColor,
                      size: 20.r,
                    ),
                    hintText: 'البريد الإلكتروني',
                    hintStyle: theme.inputDecorationTheme.hintStyle?.copyWith(
                      fontSize: 14.sp,
                    ),
                    contentPadding: EdgeInsets.symmetric(vertical: 8.h),
                    isDense: true,
                  ),
                  validator: _validateEmail,
                ),
                SizedBox(height: 20.h),
                TextFormField(
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible,
                  textAlign: TextAlign.right,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: textColor,
                    fontSize: 14.sp,
                  ),
                  decoration: InputDecoration(
                    prefixIcon: Padding(
                      padding: EdgeInsets.only(left: 8.w),
                      child: InkWell(
                        onTap: () {
                          Navigator.pushNamed(context, AppRoutes.forgotPassword);
                          print('Forgot password tapped');
                        },
                        child: Text(
                          'نسيت كلمة السر؟',
                          style: theme.textButtonTheme.style?.textStyle?.resolve({})?.copyWith(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w500,
                            color: primaryColor,
                          ),
                        ),
                      ),
                    ),
                    prefixIconConstraints: const BoxConstraints(
                      minWidth: 0,
                      minHeight: 0,
                    ),
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(
                            _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                            color: primaryColor,
                            size: 20.r,
                          ),
                          onPressed: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                        ),
                        Padding(
                          padding: EdgeInsets.only(right: 8.w),
                          child: Text(
                            'كلمة المرور',
                            style: theme.textTheme.labelMedium?.copyWith(
                              fontSize: 13.sp,
                              color: mutedTextColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    contentPadding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 0.w),
                    isDense: true,
                  ),
                  validator: _validatePassword,
                ),
                SizedBox(height: 40.h),
                SizedBox(
                  width: double.infinity,
                  height: 48.h,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _handleLogin,
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
                      minimumSize: MaterialStateProperty.all(Size(double.infinity, 48.h)),
                    ),
                    child: isLoading
                        ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 20.r,
                          width: 20.r,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.onPrimary),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Text(
                          'جاري تسجيل الدخول...',
                          style: theme.elevatedButtonTheme.style?.textStyle?.resolve({})?.copyWith(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    )
                        : Text(
                      'تسجيل الدخول',
                      style: theme.elevatedButtonTheme.style?.textStyle?.resolve({})?.copyWith(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 24.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'ليس لديك حساب؟ ',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontSize: 14.sp,
                        color: textColor,
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.pushNamed(context, AppRoutes.signup);
                      },
                      child: Text(
                        'تسجيل حساب',
                        style: theme.textButtonTheme.style?.textStyle?.resolve({})?.copyWith(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: primaryColor,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                Center(
                  child: InkWell(
                    onTap: () {
                      Navigator.pushReplacementNamed(context, AppRoutes.main);
                      print('Continue as guest tapped');
                    },
                    child: Text(
                      'المتابعة كضيف',
                      style: theme.textButtonTheme.style?.textStyle?.resolve({})?.copyWith(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w400,
                        color: mutedTextColor,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 32.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}