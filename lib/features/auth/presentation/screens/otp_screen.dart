// lib/features/auth/presentation/screens/otp_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';
import 'dart:async';

// Import your authentication provider
import 'package:grad_project/features/auth/presentation/providers/auth_provider.dart';

// Import your app routes for navigation
import 'package:grad_project/core/navigation/app_routes.dart';

class OTPScreen extends StatefulWidget {
  // FIX: Added the named parameter 'email' to the constructor
  final String? email;

  const OTPScreen({
    Key? key,
    this.email, // It must be defined here
  }) : super(key: key);

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  final TextEditingController _otpController = TextEditingController();
  String _otpCode = '';

  // Timer for resend functionality
  Timer? _timer;
  int _resendSeconds = 60;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startResendTimer();

    // FIX: Get the email directly from the widget parameter
    if (widget.email == null || widget.email!.isEmpty) {
      // Handle the case where email is not provided
      _showErrorMessage('خطأ: لم يتم العثور على البريد الإلكتروني');
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          // Use GoRouter to navigate back
          // GoRouter.of(context).go(AppRoutes.login);
          // or just pop
          Navigator.of(context).pop();
        }
      });
    }
  }

  @override
  void dispose() {
    _otpController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  // Start countdown timer for resend button
  void _startResendTimer() {
    _canResend = false;
    _resendSeconds = 60;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendSeconds == 0) {
        setState(() {
          _canResend = true;
        });
        timer.cancel();
      } else {
        setState(() {
          _resendSeconds--;
        });
      }
    });
  }

  // Handle OTP verification
  Future<void> _verifyOtp() async {
    if (_otpCode.length != 6) {
      _showErrorMessage('يرجى إدخال الرمز كاملاً (6 أرقام)');
      return;
    }

    // FIX: Use the email from the widget parameter
    if (widget.email == null || widget.email!.isEmpty) {
      _showErrorMessage('خطأ في البريد الإلكتروني');
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final success = await authProvider.verifyOTP(
      email: widget.email!,
      otp: _otpCode,
    );

    if (success && mounted) {
      _showSuccessMessage('تم التحقق من الرمز بنجاح!');

      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          // The GoRouter will now handle this navigation
          // GoRouter.of(context).go(AppRoutes.home);
          // This will be handled by the AuthGuard
        }
      });
    } else if (mounted && authProvider.error != null) {
      _showErrorMessage(authProvider.error!);
      setState(() {
        _otpCode = '';
        _otpController.clear();
      });
    }
  }

  // Handle resend OTP
  Future<void> _resendOtp() async {
    if (!_canResend || widget.email == null || widget.email!.isEmpty) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final success = await authProvider.resendOTP(email: widget.email!);

    if (success && mounted) {
      _showSuccessMessage('تم إرسال رمز جديد إلى بريدك الإلكتروني');
      _startResendTimer();
      setState(() {
        _otpCode = '';
        _otpController.clear();
      });
    } else if (mounted && authProvider.error != null) {
      _showErrorMessage(authProvider.error!);
    }
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Tajawal',
            color: Theme.of(context).colorScheme.onError,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.error,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Tajawal',
            color: Theme.of(context).colorScheme.onPrimary,
          ),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color backgroundColor = theme.scaffoldBackgroundColor;
    final Color textColor = theme.textTheme.bodyLarge!.color!;
    final Color mutedTextColor = theme.hintColor;
    final Color primaryColor = theme.primaryColor;
    final Color cardColor = theme.cardColor;
    final authProvider = Provider.of<AuthProvider>(context);
    final bool isLoading = authProvider.isLoading;

    if (widget.email == null) {
      return Scaffold(
        backgroundColor: backgroundColor,
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios_new,
                    size: 20.r,
                    color: textColor,
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
              SizedBox(height: 24.h),
              Center(
                child: Text(
                  'تحقق من البريد الإلكتروني',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: textColor,
                    fontSize: 28.sp,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              SizedBox(height: 8.h),
              Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Column(
                    children: [
                      Text(
                        'تم إرسال رمز التحقق المكون من 6 أرقام إلى',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: mutedTextColor,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w400,
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 4.h),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text(
                          // FIX: Use the email from the widget parameter
                          widget.email!,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: primaryColor,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 40.h),
              Container(
                height: 200.h,
                width: double.infinity,
                margin: EdgeInsets.symmetric(horizontal: 32.w),
                child: Image.asset(
                  'assets/images/otp_verification.png',
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 200.h,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: Icon(
                        Icons.mark_email_read_outlined,
                        size: 80.r,
                        color: primaryColor,
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 40.h),
              Directionality(
                textDirection: TextDirection.ltr,
                child: PinCodeTextField(
                  appContext: context,
                  length: 6,
                  controller: _otpController,
                  onChanged: (value) {
                    setState(() {
                      _otpCode = value;
                    });
                  },
                  obscureText: false,
                  animationType: AnimationType.fade,
                  textStyle: theme.textTheme.titleLarge?.copyWith(
                    color: textColor,
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w600,
                  ),
                  pinTheme: PinTheme(
                    shape: PinCodeFieldShape.box,
                    borderRadius: BorderRadius.circular(12.r),
                    fieldHeight: 56.h,
                    fieldWidth: 45.w,
                    activeColor: primaryColor,
                    selectedColor: primaryColor,
                    inactiveColor: primaryColor.withOpacity(0.3),
                    activeFillColor: primaryColor.withOpacity(0.1),
                    selectedFillColor: primaryColor.withOpacity(0.1),
                    inactiveFillColor: theme.cardColor,
                    borderWidth: 2,
                  ),
                  animationDuration: const Duration(milliseconds: 300),
                  enableActiveFill: true,
                  keyboardType: TextInputType.number,
                  autoDisposeControllers: false,
                ),
              ),
              SizedBox(height: 32.h),
              SizedBox(
                width: double.infinity,
                height: 56.h,
                child: ElevatedButton(
                  onPressed: (isLoading || _otpCode.length != 6) ? null : _verifyOtp,
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
                    'تأكيد الرمز',
                    style: theme.elevatedButtonTheme.style?.textStyle?.resolve({})?.copyWith(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 24.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'لم تستلم الرمز؟ ',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: 14.sp,
                      color: textColor,
                    ),
                  ),
                  InkWell(
                    onTap: (_canResend && !isLoading) ? _resendOtp : null,
                    child: Text(
                      _canResend
                          ? 'إرسال رمز جديد'
                          : 'إعادة الإرسال خلال $_resendSeconds ثانية',
                      style: theme.textButtonTheme.style?.textStyle?.resolve({})?.copyWith(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: _canResend ? primaryColor : mutedTextColor,
                        decoration: _canResend ? TextDecoration.underline : null,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 32.h),
              InkWell(
                onTap: () => Navigator.pushReplacementNamed(context, AppRoutes.login),
                child: Text(
                  'تغيير البريد الإلكتروني',
                  style: theme.textButtonTheme.style?.textStyle?.resolve({})?.copyWith(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: mutedTextColor,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              SizedBox(height: 40.h),
            ],
          ),
        ),
      ),
    );
  }
}