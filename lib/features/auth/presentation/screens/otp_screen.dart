// lib/features/auth/presentation/screens/otp_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; // Ensure flutter_screenutil is used
import 'package:pin_code_fields/pin_code_fields.dart'; // Make sure this package is in pubspec.yaml

// TODO: Import your authentication service here (e.g., for OTP verification and resend)
// import 'package:grad_project/features/auth/data/services/auth_service.dart';

// Import your app routes for navigation
import 'package:grad_project/core/navigation/app_routes.dart';

class OTPScreen extends StatefulWidget {
  // TODO: Consider passing the email or user ID to this screen
  // final String email;
  const OTPScreen({Key? key}) : super(key: key); // Add required this.email if you pass it

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  // Controller for the OTP input field (PinCodeTextField uses this internally)
  final TextEditingController _otpController = TextEditingController();

  // Stores the entered OTP code
  String _otpCode = '';

  // TODO: Add a state variable for loading indicator
  bool _isLoading = false;

  // TODO: Add a state variable for resend timer if you want to implement it
  // int _resendSeconds = 60;
  // Timer? _timer;

  @override
  void initState() {
    super.initState();
    // TODO: Start resend timer here if implemented
    // _startResendTimer();
  }

  @override
  void dispose() {
    _otpController.dispose();
    // TODO: Cancel resend timer if implemented
    // _timer?.cancel();
    super.dispose();
  }

  // TODO: Implement OTP verification logic
  Future<void> _verifyOtp() async {
    if (_otpCode.length != 5) { // Assuming OTP length is 5
      // TODO: Show an error message if OTP is not complete
      print('Please enter a complete OTP.');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'يرجى إدخال الرمز كاملاً', // Please enter the complete code
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Tajawal',
              color: Theme.of(context).colorScheme.onError, // Themed error text color
            ),
          ),
          backgroundColor: Theme.of(context).colorScheme.error, // Themed error background color
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true; // Show loading indicator
    });

    try {
      // TODO: Call your authentication service's OTP verification method here
      // Example:
      // final authService = AuthService();
      // await authService.verifyOtp(email: widget.email, otp: _otpCode);

      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 2));
      print('OTP Verification successful for code: $_otpCode');

      // TODO: Navigate to the new password screen or directly to home if it's for new user registration
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'تم التحقق من الرمز بنجاح!', // Code verified successfully!
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Tajawal',
                color: Theme.of(context).colorScheme.onPrimary, // Themed text color for success
              ),
            ),
            backgroundColor: Theme.of(context).primaryColor, // Themed primary color for success
          ),
        );
        // Example: Navigate to a screen where user can set new password
        Navigator.pushReplacementNamed(context, AppRoutes.newPassword); // Assuming a new route for setting new password
      }
    } catch (e) {
      // TODO: Handle OTP verification errors (e.g., invalid OTP, expired OTP)
      print('OTP Verification failed: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'فشل التحقق من الرمز: ${e.toString()}', // Code verification failed: [error message]
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Tajawal',
                color: Theme.of(context).colorScheme.onError, // Themed error text color
              ),
            ),
            backgroundColor: Theme.of(context).colorScheme.error, // Themed error background color
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false; // Hide loading indicator
        });
      }
    }
  }

  // TODO: Implement resend OTP logic
  Future<void> _resendOtp() async {
    // TODO: Add logic to prevent multiple resend requests too quickly
    // if (_resendSeconds > 0) return; // Prevent resending if timer is active

    setState(() {
      // _resendSeconds = 60; // Reset timer
      // _startResendTimer(); // Restart timer
    });

    try {
      // TODO: Call your authentication service's resend OTP method here
      // Example:
      // final authService = AuthService();
      // await authService.resendOtp(email: widget.email);

      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 1));
      print('Resend OTP successful');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'تم إرسال رمز جديد إلى بريدك الإلكتروني', // New code sent to your email
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Tajawal',
                color: Theme.of(context).colorScheme.onPrimary, // Themed text color for success
              ),
            ),
            backgroundColor: Theme.of(context).primaryColor, // Themed primary color for success
          ),
        );
      }
    } catch (e) {
      print('Resend OTP failed: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'فشل إرسال الرمز: ${e.toString()}', // Failed to send code: [error message]
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Tajawal',
                color: Theme.of(context).colorScheme.onError, // Themed error text color
              ),
            ),
            backgroundColor: Theme.of(context).colorScheme.error, // Themed error background color
          ),
        );
      }
    }
  }

  // TODO: Implement resend timer (optional but good UX)
  // void _startResendTimer() {
  //   _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
  //     if (_resendSeconds == 0) {
  //       timer.cancel();
  //       setState(() {}); // Rebuild to enable resend button
  //     } else {
  //       setState(() {
  //         _resendSeconds--;
  //       });
  //     }
  //   });
  // }


  @override
  Widget build(BuildContext context) {
    // Get theme-dependent colors and text styles
    final ThemeData theme = Theme.of(context);
    final Color backgroundColor = theme.scaffoldBackgroundColor;
    final Color textColor = theme.textTheme.bodyLarge!.color!; // General text color
    final Color mutedTextColor = theme.hintColor; // Muted text color
    final Color primaryColor = theme.primaryColor; // Your primary brand color
    final Color errorColor = theme.colorScheme.error; // Error color

    return Scaffold(
      backgroundColor: backgroundColor, // Themed background color
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 32.w), // Use screenutil
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 24.h), // Use screenutil

              // Back Arrow
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios,
                    size: 20.r, // Use screenutil
                    color: textColor, // Themed icon color
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),

              SizedBox(height: 8.h), // Use screenutil

              // Title
              Center(
                child: Text(
                  'تحقق من البريد الإلكتروني', // Verify Email
                  style: theme.textTheme.headlineMedium?.copyWith( // Themed headlineMedium
                    color: textColor,
                    fontSize: 22.sp, // Override font size with screenutil
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),

              SizedBox(height: 8.h), // Use screenutil

              // Subtitle
              Center(
                child: Text(
                  'تم ارسال رمز لبريدك الالكتروني لإعادة ضبط كلمة المرور', // A code has been sent to your email to reset password
                  style: theme.textTheme.bodyMedium?.copyWith( // Themed bodyMedium
                    color: mutedTextColor,
                    fontSize: 14.sp, // Override font size with screenutil
                    fontWeight: FontWeight.w400,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              SizedBox(height: 40.h), // Use screenutil

              // OTP Fields (PinCodeTextField)
              PinCodeTextField(
                appContext: context,
                length: 5, // Assuming a 5-digit OTP
                controller: _otpController,
                onChanged: (value) {
                  setState(() {
                    _otpCode = value;
                  });
                },
                onCompleted: (value) {
                  print("Completed: $value");
                  _verifyOtp();
                },
                obscureText: false,
                animationType: AnimationType.fade,
                textStyle: theme.textTheme.titleLarge?.copyWith( // Themed text style
                  color: textColor,
                  fontSize: 20.sp, // Override font size with screenutil
                  fontWeight: FontWeight.w600,
                ),
                pinTheme: PinTheme(
                  shape: PinCodeFieldShape.box,
                  borderRadius: BorderRadius.circular(6.r), // Use screenutil
                  fieldHeight: 50.h, // Use screenutil
                  fieldWidth: 50.w, // Use screenutil
                  activeColor: primaryColor, // Themed primary color
                  selectedColor: primaryColor, // Themed primary color
                  inactiveColor: primaryColor, // Themed primary color
                  // TODO: Add activeFillColor, selectedFillColor, inactiveFillColor if using enableActiveFill
                  // fieldOuterPadding: EdgeInsets.symmetric(horizontal: 4.w), // Optional: Add spacing
                ),
                animationDuration: const Duration(milliseconds: 300),
                enableActiveFill: false,
                keyboardType: TextInputType.number,
                // TODO: Add errorTextDirection if you want RTL error messages
                // errorTextDirection: TextDirection.rtl,
              ),

              SizedBox(height: 32.h), // Use screenutil

              // Continue Button (using ElevatedButtonThemeData from AppTheme)
              SizedBox(
                width: double.infinity,
                height: 48.h, // Use screenutil
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _verifyOtp,
                  // Style is now primarily from AppTheme.elevatedButtonTheme
                  // We can override disabledBackgroundColor if it's not handled by the theme
                  style: theme.elevatedButtonTheme.style?.copyWith(
                    backgroundColor: MaterialStateProperty.resolveWith<Color?>(
                          (Set<MaterialState> states) {
                        if (states.contains(MaterialState.disabled)) {
                          return primaryColor.withOpacity(0.6); // Themed disabled color
                        }
                        return theme.elevatedButtonTheme.style?.backgroundColor?.resolve(states); // Use theme's default
                      },
                    ),
                    foregroundColor: MaterialStateProperty.resolveWith<Color?>(
                          (Set<MaterialState> states) {
                        return theme.elevatedButtonTheme.style?.foregroundColor?.resolve(states);
                      },
                    ),
                    shape: MaterialStateProperty.all(RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.r), // Use screenutil
                    )),
                    minimumSize: MaterialStateProperty.all(Size(double.infinity, 48.h)), // Ensure height is applied
                  ),
                  child: _isLoading
                      ? SizedBox(
                    height: 20.r, // Use screenutil
                    width: 20.r, // Use screenutil
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.onPrimary), // Themed
                    ),
                  )
                      : Text(
                    'استمرار', // Continue
                    style: theme.elevatedButtonTheme.style?.textStyle?.resolve({})?.copyWith( // Themed text style
                      fontSize: 16.sp, // Override font size with screenutil
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),

              SizedBox(height: 16.h), // Use screenutil

              // Resend Code Button (using OutlinedButton.styleFrom)
              SizedBox(
                width: double.infinity,
                height: 44.h, // Use screenutil
                child: OutlinedButton(
                  onPressed: _isLoading ? null : _resendOtp,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: primaryColor, // Themed primary color
                    side: BorderSide(color: primaryColor), // Themed primary color for border
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r), // Use screenutil
                    ),
                  ),
                  child:
                  // TODO: Conditionally display timer if implemented
                  // _resendSeconds > 0
                  //     ? Text('إرسال رمز آخر (${_resendSeconds}s)')
                  //     :
                  Text(
                    'إرسال رمز آخر', // Resend Code
                    style: theme.textButtonTheme.style?.textStyle?.resolve({})?.copyWith( // Themed text style
                      fontSize: 14.sp, // Override font size with screenutil
                      fontWeight: FontWeight.w500,
                      color: primaryColor, // Ensure text color is primary
                    ),
                  ),
                ),
              ),

              SizedBox(height: 32.h), // Use screenutil
            ],
          ),
        ),
      ),
    );
  }
}