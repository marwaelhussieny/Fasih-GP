// lib/features/auth/presentation/screens/new_password_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

// Import your authentication provider
import 'package:grad_project/features/auth/presentation/providers/auth_provider.dart';
import 'package:grad_project/core/navigation/app_routes.dart';

class NewPasswordScreen extends StatefulWidget {
  final String? resetToken;

  const NewPasswordScreen({
    Key? key,
    this.resetToken,
  }) : super(key: key);

  @override
  State<NewPasswordScreen> createState() => _NewPasswordScreenState();
}

class _NewPasswordScreenState extends State<NewPasswordScreen> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  String? _resetToken;

  // Password strength indicators
  bool _hasMinLength = false;
  bool _hasUppercase = false;
  bool _hasLowercase = false;
  bool _hasDigits = false;
  bool _hasSpecialChars = false;

  @override
  void initState() {
    super.initState();
    // Extract token from route arguments if not provided directly
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final arguments = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      _resetToken = widget.resetToken ?? arguments?['resetToken'];

      if (_resetToken == null || _resetToken!.isEmpty) {
        _showErrorAndNavigateBack('رمز إعادة التعيين غير صالح أو منتهي الصلاحية');
      }
    });
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _checkPasswordStrength(String password) {
    setState(() {
      _hasMinLength = password.length >= 8;
      _hasUppercase = password.contains(RegExp(r'[A-Z]'));
      _hasLowercase = password.contains(RegExp(r'[a-z]'));
      _hasDigits = password.contains(RegExp(r'[0-9]'));
      _hasSpecialChars = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    });
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'يرجى إدخال كلمة المرور الجديدة';
    }
    if (value.length < 8) {
      return 'يجب أن تكون كلمة المرور 8 أحرف على الأقل';
    }
    if (!_hasUppercase) {
      return 'يجب أن تحتوي كلمة المرور على حرف كبير واحد على الأقل';
    }
    if (!_hasLowercase) {
      return 'يجب أن تحتوي كلمة المرور على حرف صغير واحد على الأقل';
    }
    if (!_hasDigits) {
      return 'يجب أن تحتوي كلمة المرور على رقم واحد على الأقل';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'يرجى تأكيد كلمة المرور';
    }
    if (value != _passwordController.text) {
      return 'كلمات المرور غير متطابقة';
    }
    return null;
  }

  void _showErrorAndNavigateBack(String message) {
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
    Navigator.pushReplacementNamed(context, AppRoutes.forgotPassword);
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

  Future<void> _resetPassword() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    if (_resetToken == null || _resetToken!.isEmpty) {
      _showErrorAndNavigateBack('رمز إعادة التعيين غير صالح');
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      await authProvider.resetPassword(
        token: _resetToken!,
        newPassword: _passwordController.text,
      );

      if (authProvider.error == null) {
        if (mounted) {
          _showSuccessMessage('تم تغيير كلمة المرور بنجاح!');

          // Navigate to login screen after a short delay
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) {
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.login,
                    (route) => false,
              );
            }
          });
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                authProvider.error!,
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
      }
    } catch (e) {
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
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Widget _buildPasswordStrengthIndicator() {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;
    final errorColor = theme.colorScheme.error;
    final successColor = Colors.green;

    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: primaryColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'متطلبات كلمة المرور:',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: primaryColor,
              fontWeight: FontWeight.w600,
              fontSize: 14.sp,
            ),
          ),
          SizedBox(height: 8.h),
          _buildPasswordRequirement(
            'على الأقل 8 أحرف',
            _hasMinLength,
            successColor,
            errorColor,
          ),
          _buildPasswordRequirement(
            'حرف كبير واحد على الأقل (A-Z)',
            _hasUppercase,
            successColor,
            errorColor,
          ),
          _buildPasswordRequirement(
            'حرف صغير واحد على الأقل (a-z)',
            _hasLowercase,
            successColor,
            errorColor,
          ),
          _buildPasswordRequirement(
            'رقم واحد على الأقل (0-9)',
            _hasDigits,
            successColor,
            errorColor,
          ),
          _buildPasswordRequirement(
            'رمز خاص (اختياري) (!@#\$%^&*)',
            _hasSpecialChars,
            successColor,
            Colors.grey,
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordRequirement(
      String text,
      bool isValid,
      Color validColor,
      Color invalidColor,
      ) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2.h),
      child: Row(
        children: [
          Icon(
            isValid ? Icons.check_circle : Icons.cancel,
            size: 16.r,
            color: isValid ? validColor : invalidColor,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12.sp,
                color: isValid ? validColor : invalidColor,
                fontFamily: 'Tajawal',
              ),
            ),
          ),
        ],
      ),
    );
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
                    'كلمة مرور جديدة',
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
                      'قم بإنشاء كلمة مرور قوية وآمنة لحسابك',
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

                // Image (hidden when keyboard is visible)
                if (!keyboardVisible)
                  Container(
                    height: screenHeight * 0.2,
                    width: double.infinity,
                    margin: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Image.asset(
                      'assets/images/new_password.png',
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: screenHeight * 0.2,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                          child: Icon(
                            Icons.lock_reset_outlined,
                            size: 60.r,
                            color: primaryColor,
                          ),
                        );
                      },
                    ),
                  ),
                SizedBox(height: keyboardVisible ? 16.h : 24.h),

                // Password Input Field
                TextFormField(
                  controller: _passwordController,
                  textAlign: TextAlign.right,
                  obscureText: !_isPasswordVisible,
                  validator: _validatePassword,
                  onChanged: _checkPasswordStrength,
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
                        Icons.lock_outline,
                        color: primaryColor,
                        size: 20.r,
                      ),
                    ),
                    suffixIcon: IconButton(
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
                    hintText: 'كلمة المرور الجديدة',
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
                SizedBox(height: 20.h),

                // Confirm Password Input Field
                TextFormField(
                  controller: _confirmPasswordController,
                  textAlign: TextAlign.right,
                  obscureText: !_isConfirmPasswordVisible,
                  validator: _validateConfirmPassword,
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
                        Icons.lock_outline,
                        color: primaryColor,
                        size: 20.r,
                      ),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isConfirmPasswordVisible ? Icons.visibility_off : Icons.visibility,
                        color: primaryColor,
                        size: 20.r,
                      ),
                      onPressed: () {
                        setState(() {
                          _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                        });
                      },
                    ),
                    hintText: 'تأكيد كلمة المرور',
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
                SizedBox(height: 16.h),

                // Password strength indicator
                _buildPasswordStrengthIndicator(),
                SizedBox(height: 32.h),

                // Reset Password Button
                SizedBox(
                  width: double.infinity,
                  height: 56.h,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _resetPassword,
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
                      'تأكيد كلمة المرور الجديدة',
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
                    onPressed: () => Navigator.pushNamedAndRemoveUntil(
                      context,
                      AppRoutes.login,
                          (route) => false,
                    ),
                    child: Text(
                      'العودة إلى تسجيل الدخول',
                      style: theme.textButtonTheme.style?.textStyle?.resolve({})?.copyWith(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: primaryColor,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 40.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}